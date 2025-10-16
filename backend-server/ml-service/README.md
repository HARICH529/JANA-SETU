# ML Classification Service

Enhanced ML service for civic issue classification with multi-modal support.

## Features

- **Text Classification**: Analyze issue descriptions using BART
- **Image Classification**: Analyze images using CLIP
- **Audio Classification**: Transcribe audio using Whisper, then classify text
- **Smart Title Generation**: Auto-generate concise titles using BART summarization
- **Conflict Detection**: Detect and report conflicts between text and image predictions
- **Severity Prioritization**: Automatically select higher severity when combining predictions

## Models Used

- **CLIP**: `openai/clip-vit-base-patch32` for image classification
- **BART**: `facebook/bart-large-mnli` for zero-shot text classification
- **BART CNN**: `facebook/bart-large-cnn` for title summarization
- **Whisper**: `openai/whisper-base` for audio transcription

## Cache Configuration

All models are cached to `F:\ml-cache` to save space on system drive:
- Hugging Face models: `F:\ml-cache\huggingface`
- PyTorch models: `F:\ml-cache\torch`
- Transformers cache: `F:\ml-cache\transformers`

## Classification Labels

### Severity
- Minor issue
- Moderate issue  
- Severe issue

### Departments
- Sanitation and Waste Management
- Roads and Transport
- Electricity and Streetlights
- Water Supply and Drainage
- Public Health
- Environment
- Public Safety

## API Endpoints

### POST /classify
Classify text, image, or both.

**Request:**
```json
{
  "text": "Overflowing garbage near park",
  "image_url": "https://example.com/image.jpg",
  "audio_url": "https://example.com/audio.wav"
}
```

**Response:**
```json
{
  "severity": "HIGH",
  "department": "Sanitation",
  "title": "Overflowing garbage issue",
  "confidence": {
    "severity": 0.892,
    "department": 0.756
  },
  "conflicts": "Text suggests Sanitation, image suggests Roads"
}
```

### POST /classify-audio
Upload and classify audio file directly.

**Request:** Multipart form with audio file

**Response:**
```json
{
  "transcribed_text": "There is a big pothole on main street",
  "severity": "MEDIUM",
  "department": "Roads",
  "title": "Pothole on street",
  "confidence": {
    "severity": 0.834,
    "department": 0.912
  }
}
```

### GET /health
Health check endpoint.

## Setup Instructions

1. **Install Dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Set Cache Directory:**
   ```bash
   # Windows
   set_cache.bat
   
   # Or manually set environment variables
   set HF_HOME=F:\ml-cache\huggingface
   set TORCH_HOME=F:\ml-cache\torch
   set TRANSFORMERS_CACHE=F:\ml-cache\transformers
   ```

3. **Start Service:**
   ```bash
   # Start both API and worker
   start.bat
   
   # Or start individually
   python app.py      # API server on port 8000
   python worker.py   # Background worker for queue processing
   ```

4. **Test Service:**
   ```bash
   python test_ml.py
   ```

## Conflict Resolution Logic

When both text and image are provided:

1. **Severity**: Always pick the higher severity level
2. **Department**: Use text prediction, but report conflicts if image disagrees
3. **Title**: Always use text-generated title for better context

## Integration with Backend

The service integrates with the main backend through:

1. **Redis Queue**: Reports are queued for async processing
2. **Worker Process**: Processes classification jobs and updates database
3. **Webhook**: Notifies backend when classification is complete

## File Structure

```
ml-service/
├── app.py              # FastAPI service
├── worker.py           # Background worker
├── classifier.py       # Standalone classification script
├── test_ml.py         # Test script
├── requirements.txt    # Python dependencies
├── start.bat          # Windows startup script
├── set_cache.bat      # Cache setup script
└── README.md          # This file
```

## Performance Notes

- First run will download models (~2-3 GB total)
- Subsequent runs use cached models for faster startup
- Audio processing requires librosa for audio loading
- GPU acceleration supported if CUDA available

## Troubleshooting

1. **Models not downloading**: Check internet connection and cache permissions
2. **Audio processing fails**: Ensure librosa and ffmpeg are installed
3. **Memory issues**: Consider using smaller model variants
4. **Cache issues**: Clear F:\ml-cache and restart service