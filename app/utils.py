import os
from dotenv import load_dotenv
from huggingface_hub import InferenceClient
from langdetect import detect

load_dotenv()

client = InferenceClient(
    api_key=os.getenv("HF_TOKEN")
)


def call_llm(prompt, max_tokens=200):

    response = client.chat_completion(
        model="meta-llama/Llama-3.2-3B-Instruct",
        messages=[
            {
                "role": "user",
                "content": prompt
            }
        ],
        max_tokens=max_tokens,
        temperature=0.01,
    )

    return response.choices[0].message.content




def arabic_default_message():
    return """
    يبدو أنني لم أتمكن من العثور على إجابة لسؤالك. يُرجى المحاولة بسؤال آخر.
    """


def english_default_message():
    return "“Sorry. it seems that I can't find an answer for your question. please try another question"


def is_in_arabic(question):
    return detect(question) == 'ar'


def get_default_message(question):
    if not is_in_arabic(question):
        return english_default_message()
    else:
        return arabic_default_message()