DISEASE_DIAGNOSIS_PROMPT_EN = """Analyze this image of a chicken for signs of disease.

Provide a structured assessment:
1. Observable symptoms (swelling, discoloration, discharge, lesions, posture abnormalities)
2. Most likely diseases (ranked by probability)
3. Immediate actions the farmer should take TODAY
4. Whether a veterinarian should be contacted urgently
5. Recommended medicines and dosages (if applicable)

IMPORTANT SAFETY RULES:
- Always mention withdrawal periods for any medicines recommended.
- Never recommend banned antibiotics or growth hormones.
- For suspected Avian Influenza or Newcastle Disease, recommend contacting the local District Livestock Officer immediately.
- Use practical, measurable quantities (ml, mg/kg body weight, grams per liter of water).

If you cannot determine the disease from the image, explain what additional information or photos would help."""

DISEASE_DIAGNOSIS_PROMPT_BN = """এই মুরগির ছবি বিশ্লেষণ করে রোগের লক্ষণ চিহ্নিত করুন।

একটি কাঠামোবদ্ধ মূল্যায়ন দিন:
১. দৃশ্যমান উপসর্গ (ফোলা, বিবর্ণতা, স্রাব, ক্ষত, অস্বাভাবিক ভঙ্গি)
২. সম্ভাব্য রোগ (সম্ভাবনার ক্রমানুসারে)
৩. কৃষক আজই কী পদক্ষেপ নিতে পারেন
৪. জরুরিভাবে পশুচিকিৎসকের সাথে যোগাযোগ করা দরকার কিনা
৫. প্রস্তাবিত ওষুধ ও মাত্রা (প্রযোজ্য হলে)

গুরুত্বপূর্ণ নিরাপত্তা নিয়ম:
- প্রতিটি ওষুধের withdrawal period অবশ্যই উল্লেখ করুন।
- নিষিদ্ধ অ্যান্টিবায়োটিক বা গ্রোথ হরমোন সুপারিশ করবেন না।
- সন্দেহজনক বার্ড ফ্লু বা নিউক্যাসল রোগের ক্ষেত্রে স্থানীয় জেলা প্রাণিসম্পদ কর্মকর্তার সাথে যোগাযোগ করতে বলুন।

ছবি থেকে রোগ নির্ণয় করা সম্ভব না হলে, কী অতিরিক্ত তথ্য বা ছবি প্রয়োজন তা ব্যাখ্যা করুন।"""


def get_diagnosis_prompt(language: str = "en") -> str:
    if language.lower().startswith("bn"):
        return DISEASE_DIAGNOSIS_PROMPT_BN
    return DISEASE_DIAGNOSIS_PROMPT_EN
