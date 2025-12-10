import express from 'express';
import fetch from 'node-fetch';
import cors from 'cors';
import dotenv from 'dotenv';

dotenv.config();
const app = express();
app.use(cors());
app.use(express.json());

app.post('/api/ai', async (req, res) => {
  const { query } = req.body;
  try {
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'gpt-4-mini',
        messages: [
          { role: 'system', content: 'You are a helpful cosmic AI assistant.' },
          { role: 'user', content: query }
        ],
        max_tokens: 300
      })
    });

    const data = await response.json();
    res.json(data);
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
});

app.listen(3000, () => console.log('Server running on http://localhost:3000'));
