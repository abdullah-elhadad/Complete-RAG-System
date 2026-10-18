# Complete RAG System — From LLM & Retrieval to AWS Deployment

A complete Retrieval-Augmented Generation (RAG) application built with Python, LangChain, ChromaDB, Ollama, Streamlit, Docker, Amazon ECR, and Amazon EC2.

The project supports both **Arabic and English documents** and uses separate embedding configurations and vector stores for each language.

---

## Project Architecture

The application follows this general flow:

```text
Documents
   │
   ▼
Document Loading
   │
   ▼
Text Splitting
   │
   ▼
Embeddings
   │
   ▼
ChromaDB
   │
   ▼
Retriever
   │
   ▼
LLM (Ollama)
   │
   ▼
RAG Response
   │
   ▼
Streamlit UI
```

---

## Project Structure

```text
Complete-RAG-System-From-LLM-Retrieval-to-AWS-Deployment/
│
├── app/
│   ├── main.py
│   ├── indexing.py
│   ├── llama_model.py
│   └── utils.py
│
├── assets/
│
├── data/
│   ├── raw/
│   │   ├── ar.docx
│   │   └── en.pdf
│   │
│   └── processed/
│
├── tests/
│
├── .env
├── .env.example
├── .gitignore
├── Dockerfile
├── requirements.txt
├── README.md
└── start_services.sh
```

---

# Running Locally

## 1. Create the Conda Environment

The project uses Python 3.11.

```bash
conda create -n rag-project python=3.11
```

Activate the environment:

```bash
conda activate rag-project
```

---

## 2. Install Dependencies

```bash
pip install -r requirements.txt
```

---

## 3. Configure Environment Variables

Create a `.env` file:

```env
HF_TOKEN=your_huggingface_token
```

The Hugging Face token is used when downloading the required models.

---

## 4. Run Ollama

Make sure Ollama is installed and running.

Check the installation:

```bash
ollama --version
```

The project uses Ollama for local LLM inference and embeddings.

The main LLM used by the application is:

```text
llama3:8b
```

The English embedding model is:

```text
nomic-embed-text
```

---

# Build the Vector Stores

The project uses ChromaDB as the vector database.

Run the indexing script:

```bash
python app/indexing.py
```

This creates the vector stores used for document retrieval.

The project uses:

* `UBC-NLP/ARBERT` for Arabic documents.
* `nomic-embed-text` through Ollama for English documents.

---

# Run the Streamlit Application

From the project root:

```bash
python -m streamlit run app/main.py --server.port 5000
```

The application will be available at:

```text
http://localhost:5000
```

---

# Docker

## Build the Docker Image

Build the image locally:

```bash
docker build -t complete-rag:latest .
```

Check the image:

```bash
docker images
```

---

## Run the Docker Container

```bash
docker run -d \
  --name rag-app \
  -p 5000:5000 \
  --env-file .env \
  complete-rag:latest
```

Check the running container:

```bash
docker ps
```

Check the application logs:

```bash
docker logs rag-app
```

Open the application:

```text
http://localhost:5000
```

---

# Amazon Web Services

The project is deployed using:

```text
AWS ECR
   │
   ▼
Amazon EC2
   │
   ▼
Docker Container
   │
   ▼
Streamlit RAG Application
```

## AWS Configuration

AWS CLI is configured with:

```text
Region: eu-west-1
Output: json
```

Check AWS CLI:

```bash
aws --version
```

Configure AWS if needed:

```bash
aws configure
```

---

# Amazon ECR

The Docker image is stored in Amazon Elastic Container Registry (ECR).

## ECR Repository

```text
ecs-complete-rag-udemy/home
```

Region:

```text
eu-west-1
```

AWS Account:

```text
733136234625
```

---

## Login to ECR

```bash
aws ecr get-login-password --region eu-west-1 | \
docker login \
--username AWS \
--password-stdin \
733136234625.dkr.ecr.eu-west-1.amazonaws.com
```

---

## Tag the Docker Image

```bash
docker tag complete-rag:latest \
733136234625.dkr.ecr.eu-west-1.amazonaws.com/ecs-complete-rag-udemy/home:latest
```

---

## Push the Image to ECR

```bash
docker push \
733136234625.dkr.ecr.eu-west-1.amazonaws.com/ecs-complete-rag-udemy/home:latest
```

---

# Amazon EC2

The application is deployed on an Amazon EC2 GPU instance.

The EC2 instance uses an NVIDIA GPU-enabled Deep Learning AMI.

The EC2 instance is responsible for:

1. Pulling the Docker image from ECR.
2. Running the Docker container.
3. Running the RAG application.
4. Serving the Streamlit interface.

---

# Connect to EC2

Example SSH command:

```bash
ssh -i "complete-rag.pem" \
ec2-user@ec2-34-242-94-229.eu-west-1.compute.amazonaws.com
```

> The SSH hostname may change when the EC2 instance is restarted. Use the current public DNS provided by AWS.

---

# Pull the Docker Image on EC2

Login to ECR:

```bash
aws ecr get-login-password --region eu-west-1 | \
docker login \
--username AWS \
--password-stdin \
733136234625.dkr.ecr.eu-west-1.amazonaws.com
```

Pull the latest image:

```bash
docker pull \
733136234625.dkr.ecr.eu-west-1.amazonaws.com/ecs-complete-rag-udemy/home:latest
```

---

# Run the Application on EC2

Create the environment file:

```bash
nano .env
```

Add the required variables:

```env
HF_TOKEN=your_huggingface_token
```

Run the container:

```bash
docker run -d \
  --name rag-app \
  -p 5000:5000 \
  --env-file .env \
  733136234625.dkr.ecr.eu-west-1.amazonaws.com/ecs-complete-rag-udemy/home:latest
```

Check the container:

```bash
docker ps
```

Check the logs:

```bash
docker logs rag-app
```

---

# AWS Security Group

The EC2 Security Group should allow:

| Port | Purpose               |
| ---- | --------------------- |
| 22   | SSH                   |
| 5000 | Streamlit application |

The application can then be accessed through:

```text
http://<EC2-PUBLIC-IP>:5000
```

---

# Useful Docker Commands

## List Images

```bash
docker images
```

## List Running Containers

```bash
docker ps
```

## List All Containers

```bash
docker ps -a
```

## View Logs

```bash
docker logs rag-app
```

## Enter the Container

```bash
docker exec -it rag-app bash
```

## Stop the Container

```bash
docker stop rag-app
```

## Remove the Container

```bash
docker rm -f rag-app
```

---

# Docker Disk Management

Docker images, build cache, and unused layers can consume significant disk space.

Check Docker disk usage:

```bash
docker system df
```

Check build cache:

```bash
docker builder du
```

When disk space is critically low, unused Docker resources can be removed.

For example:

```bash
docker builder prune
```

or, when a complete cleanup is intentionally required:

```bash
docker system prune
```

> Be careful with aggressive Docker cleanup commands because unused images and build cache may be deleted.

---

# Technologies Used

* Python 3.11
* Streamlit
* LangChain
* ChromaDB
* Ollama
* Llama 3 8B
* ARBERT
* Sentence Transformers
* Hugging Face
* Docker
* Amazon ECR
* Amazon EC2
* NVIDIA CUDA / GPU environment

---

# RAG Components

### Document Processing

Documents are loaded from:

```text
data/raw/
```

Current document types include:

```text
PDF
DOCX
```

### Embeddings

Arabic:

```text
UBC-NLP/ARBERT
```

English:

```text
nomic-embed-text
```

### Vector Database

```text
ChromaDB
```

### Retrieval

The application retrieves the most relevant document chunks before sending the context to the LLM.

Current retrieval configuration uses:

```text
k = 3
```

### LLM

```text
llama3:8b
```

The model runs locally through Ollama.

---

# Application Flow

```text
User Question
      │
      ▼
Language Detection
      │
      ▼
Select Language-Specific Vector Store
      │
      ▼
Retrieve Relevant Documents
      │
      ▼
Build RAG Context
      │
      ▼
Llama 3 8B
      │
      ▼
Generated Answer
      │
      ▼
Streamlit UI
```

---

# Deployment Flow

```text
Local Development
       │
       ▼
Docker Build
       │
       ▼
Docker Image
       │
       ▼
Amazon ECR
       │
       ▼
Amazon EC2
       │
       ▼
Docker Container
       │
       ▼
Streamlit Application
```

---

# Project Status

The project currently supports:

* Arabic and English document ingestion.
* Language-specific embeddings.
* ChromaDB vector stores.
* Local LLM inference with Ollama.
* RAG-based question answering.
* Streamlit user interface.
* Docker containerization.
* Amazon ECR image storage.
* Amazon EC2 deployment.

Future improvements can include:

* CI/CD pipeline.
* Better evaluation of retrieval quality.
* Reranking.
* Agentic RAG.
* Multimodal RAG.
* Production monitoring.
* Scalable inference architecture.
