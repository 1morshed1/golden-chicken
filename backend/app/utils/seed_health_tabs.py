"""Seed health tabs into the database."""

import asyncio

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import async_session_factory
from app.models.health import DiseaseSeverity, HealthTab

HEALTH_TABS_DATA = [
    {
        "disease_name_en": "Newcastle Disease",
        "disease_name_bn": "রাণীক্ষেত রোগ",
        "severity": DiseaseSeverity.CRITICAL,
        "symptom_count": 8,
        "symptoms": {
            "en": [
                "Sudden high mortality",
                "Greenish watery diarrhea",
                "Twisting of neck (torticollis)",
                "Respiratory distress / gasping",
                "Drop in egg production",
                "Soft-shelled eggs",
                "Swollen eyes",
                "Loss of appetite",
            ],
            "bn": [
                "হঠাৎ বেশি মৃত্যু",
                "সবুজাভ পাতলা পায়খানা",
                "ঘাড় বেঁকে যাওয়া",
                "শ্বাসকষ্ট / হাঁপানি",
                "ডিম উৎপাদন কমে যাওয়া",
                "নরম খোসার ডিম",
                "চোখ ফোলা",
                "খাবার বন্ধ করা",
            ],
        },
        "prefilled_prompt_en": "My chickens are showing signs of Newcastle Disease. I am seeing sudden deaths, greenish diarrhea, and some birds have twisted necks. What should I do immediately?",
        "prefilled_prompt_bn": "আমার মুরগিগুলোতে রাণীক্ষেত রোগের লক্ষণ দেখা যাচ্ছে। হঠাৎ মৃত্যু, সবুজ পায়খানা, কিছু মুরগির ঘাড় বাঁকা। আমি এখন কী করব?",
        "category": "viral",
        "icon": "🦠",
        "sort_order": 1,
    },
    {
        "disease_name_en": "Avian Influenza (Bird Flu)",
        "disease_name_bn": "বার্ড ফ্লু",
        "severity": DiseaseSeverity.CRITICAL,
        "symptom_count": 7,
        "symptoms": {
            "en": [
                "Sudden death without symptoms",
                "Swollen head, comb, and wattles",
                "Purple discoloration of comb",
                "Severe drop in egg production",
                "Respiratory signs",
                "Watery diarrhea",
                "Lack of energy / huddling",
            ],
            "bn": [
                "কোনো লক্ষণ ছাড়াই হঠাৎ মৃত্যু",
                "মাথা, ঝুঁটি ও কানের লতি ফোলা",
                "ঝুঁটি বেগুনি হয়ে যাওয়া",
                "ডিম উৎপাদন মারাত্মক কমে যাওয়া",
                "শ্বাসতন্ত্রের সমস্যা",
                "পাতলা পায়খানা",
                "দুর্বলতা / এক জায়গায় জড়ো হওয়া",
            ],
        },
        "prefilled_prompt_en": "I suspect Bird Flu in my flock. Many birds are dying suddenly, some have swollen purple combs. What should I do?",
        "prefilled_prompt_bn": "আমার খামারে বার্ড ফ্লু সন্দেহ করছি। অনেক মুরগি হঠাৎ মারা যাচ্ছে, কিছুর ঝুঁটি বেগুনি ও ফোলা। কী করব?",
        "category": "viral",
        "icon": "⚠️",
        "sort_order": 2,
    },
    {
        "disease_name_en": "Marek's Disease",
        "disease_name_bn": "ম্যারেক্স রোগ",
        "severity": DiseaseSeverity.HIGH,
        "symptom_count": 6,
        "symptoms": {
            "en": [
                "Paralysis of legs/wings",
                "Weight loss",
                "Grey iris (ocular form)",
                "Skin tumors",
                "Uneven pupils",
                "Mortality in young birds (8-20 weeks)",
            ],
            "bn": [
                "পা/ডানা প্যারালাইসিস",
                "ওজন কমে যাওয়া",
                "চোখের মণি ধূসর হওয়া",
                "চামড়ায় টিউমার",
                "অসমান চোখের তারা",
                "কম বয়সী মুরগিতে মৃত্যু (৮-২০ সপ্তাহ)",
            ],
        },
        "prefilled_prompt_en": "Some of my young chickens (12 weeks old) are showing leg paralysis and weight loss. Could this be Marek's Disease? What treatment is available?",
        "prefilled_prompt_bn": "আমার কিছু বাচ্চা মুরগি (১২ সপ্তাহ বয়স) পা প্যারালাইসিস ও ওজন কমছে। এটা কি ম্যারেক্স রোগ? কী চিকিৎসা আছে?",
        "category": "viral",
        "icon": "🔬",
        "sort_order": 3,
    },
    {
        "disease_name_en": "Coccidiosis",
        "disease_name_bn": "ককসিডিওসিস",
        "severity": DiseaseSeverity.HIGH,
        "symptom_count": 6,
        "symptoms": {
            "en": [
                "Bloody or watery droppings",
                "Ruffled feathers",
                "Decreased feed intake",
                "Weight loss / poor growth",
                "Pale comb and wattles",
                "Huddling with droopy wings",
            ],
            "bn": [
                "রক্তমিশ্রিত বা পাতলা পায়খানা",
                "এলোমেলো পালক",
                "খাওয়া কমে যাওয়া",
                "ওজন কমা / দুর্বল বৃদ্ধি",
                "ঝুঁটি ও কানের লতি ফ্যাকাশে",
                "ডানা ঝুলিয়ে একত্রে জড়ো হওয়া",
            ],
        },
        "prefilled_prompt_en": "My broiler chicks have bloody droppings and are not eating well. I think it could be Coccidiosis. What medicine should I give and what dosage?",
        "prefilled_prompt_bn": "আমার ব্রয়লার বাচ্চাদের রক্ত পায়খানা হচ্ছে এবং ভালো খাচ্ছে না। মনে হচ্ছে ককসিডিওসিস। কোন ওষুধ কতটুকু দেব?",
        "category": "parasitic",
        "icon": "🩸",
        "sort_order": 4,
    },
    {
        "disease_name_en": "Infectious Bronchitis",
        "disease_name_bn": "সংক্রামক ব্রংকাইটিস",
        "severity": DiseaseSeverity.MEDIUM,
        "symptom_count": 6,
        "symptoms": {
            "en": [
                "Sneezing and coughing",
                "Nasal discharge",
                "Wet eyes / tearing",
                "Reduced egg production",
                "Misshapen / rough eggs",
                "Gasping in chicks",
            ],
            "bn": [
                "হাঁচি ও কাশি",
                "নাক দিয়ে পানি পড়া",
                "চোখ ভেজা / পানি পড়া",
                "ডিম উৎপাদন কমে যাওয়া",
                "বিকৃত / রুক্ষ খোসার ডিম",
                "বাচ্চা মুরগির শ্বাসকষ্ট",
            ],
        },
        "prefilled_prompt_en": "My layer flock is sneezing a lot, some have nasal discharge, and egg production has dropped. Could this be Infectious Bronchitis?",
        "prefilled_prompt_bn": "আমার লেয়ার মুরগিগুলো অনেক হাঁচি দিচ্ছে, কিছুর নাক দিয়ে পানি পড়ছে, ডিমও কমে গেছে। এটা কি সংক্রামক ব্রংকাইটিস?",
        "category": "viral",
        "icon": "🫁",
        "sort_order": 5,
    },
    {
        "disease_name_en": "Fowl Pox",
        "disease_name_bn": "বসন্ত রোগ",
        "severity": DiseaseSeverity.MEDIUM,
        "symptom_count": 5,
        "symptoms": {
            "en": [
                "Wart-like lesions on comb, wattles, face",
                "Scabs on unfeathered skin",
                "Lesions in mouth/throat (wet pox)",
                "Difficulty breathing (wet pox)",
                "Reduced egg production",
            ],
            "bn": [
                "ঝুঁটি, কানের লতি, মুখে আঁচিলের মতো ক্ষত",
                "পালকহীন চামড়ায় খোসপাঁচড়া",
                "মুখ/গলায় ক্ষত (ভেজা পক্স)",
                "শ্বাসকষ্ট (ভেজা পক্স)",
                "ডিম উৎপাদন কমে যাওয়া",
            ],
        },
        "prefilled_prompt_en": "My chickens have wart-like bumps on their combs and faces. Some have scabs. Is this Fowl Pox? What should I do?",
        "prefilled_prompt_bn": "আমার মুরগিগুলোর ঝুঁটি ও মুখে আঁচিলের মতো ফোলা দেখা যাচ্ছে। কিছুতে খোসপাঁচড়া আছে। এটা কি বসন্ত রোগ? কী করব?",
        "category": "viral",
        "icon": "🔴",
        "sort_order": 6,
    },
]


async def seed_health_tabs() -> None:
    async with async_session_factory() as db:
        existing = await db.execute(select(HealthTab).limit(1))
        if existing.scalar_one_or_none():
            print("Health tabs already seeded, skipping.")
            return

        for tab_data in HEALTH_TABS_DATA:
            tab = HealthTab(**tab_data)
            db.add(tab)

        await db.commit()
        print(f"Seeded {len(HEALTH_TABS_DATA)} health tabs.")


if __name__ == "__main__":
    asyncio.run(seed_health_tabs())
