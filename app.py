from fastapi import FastAPI, Request
from pydantic import BaseModel

app = FastAPI()

class TextRequest(BaseModel):
    text: str

@app.post("/analyze")
async def analyze_text(request: TextRequest):
    text = request.text
    word_count = len(text.split())
    character_count = len(text)
    return {
        "original_text": text,
        "word_count": word_count,
        "character_count": character_count
    }