#!/bin/sh

# Start Ollama
ollama serve &

# Wait for Ollama
sleep 10

# Pull only the embedding model
ollama pull nomic-embed-text

# Start Streamlit

cd /src
python3 -m streamlit run app/main.py --server.port 5000 --server.address 0.0.0.0