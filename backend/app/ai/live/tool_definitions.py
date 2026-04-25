from google.genai import types as genai_types

LIVE_AI_TOOLS = [
    genai_types.Tool(function_declarations=[
        genai_types.FunctionDeclaration(
            name="get_weather",
            description="Get current weather and forecast for the farmer's location",
            parameters=genai_types.Schema(
                type="OBJECT",
                properties={
                    "location": genai_types.Schema(
                        type="STRING",
                        description="Region name in Bangladesh (e.g. dhaka, gazipur, rajshahi)",
                    ),
                },
            ),
        ),
        genai_types.FunctionDeclaration(
            name="get_market_prices",
            description="Get current egg, meat, and feed prices from local markets",
            parameters=genai_types.Schema(
                type="OBJECT",
                properties={
                    "product_type": genai_types.Schema(
                        type="STRING",
                        enum=["egg", "broiler_meat", "feed", "chick"],
                        description="Type of product to check prices for",
                    ),
                },
            ),
        ),
        genai_types.FunctionDeclaration(
            name="get_flock_status",
            description="Get current bird counts, egg production, and flock health status for a shed",
            parameters=genai_types.Schema(
                type="OBJECT",
                properties={
                    "shed_name": genai_types.Schema(
                        type="STRING",
                        description="Name of the shed to check (optional, checks all if not given)",
                    ),
                },
            ),
        ),
        genai_types.FunctionDeclaration(
            name="get_pending_tasks",
            description="Get today's pending farm tasks and overdue items",
            parameters=genai_types.Schema(
                type="OBJECT",
                properties={},
            ),
        ),
    ]),
]
