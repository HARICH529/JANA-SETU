const axios = require('axios');

class ExternalMLService {
  constructor() {
    this.huggingFaceAPI = 'https://api-inference.huggingface.co/models/';
    this.apiKey = process.env.HUGGINGFACE_API_KEY;
  }

  async classifyText(text) {
    try {
      // Use Hugging Face Inference API (free tier)
      const response = await axios.post(
        `${this.huggingFaceAPI}facebook/bart-large-mnli`,
        {
          inputs: text,
          parameters: {
            candidate_labels: ["roads", "water", "electricity", "sanitation", "parks", "other"]
          }
        },
        {
          headers: {
            'Authorization': `Bearer ${this.apiKey}`,
            'Content-Type': 'application/json'
          }
        }
      );

      return {
        department: response.data.labels[0],
        severity: this.inferSeverity(text),
        confidence: response.data.scores[0]
      };
    } catch (error) {
      console.error('External ML API error:', error);
      return this.fallbackClassification(text);
    }
  }

  inferSeverity(text) {
    const criticalWords = ['emergency', 'urgent', 'dangerous', 'severe'];
    const highWords = ['broken', 'damaged', 'not working', 'blocked'];
    
    const textLower = text.toLowerCase();
    
    if (criticalWords.some(word => textLower.includes(word))) return 'CRITICAL';
    if (highWords.some(word => textLower.includes(word))) return 'HIGH';
    return 'MEDIUM';
  }

  fallbackClassification(text) {
    // Simple keyword-based fallback
    return {
      department: 'Other',
      severity: 'MEDIUM',
      confidence: 0.5
    };
  }
}

module.exports = new ExternalMLService();