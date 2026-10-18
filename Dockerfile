# صورة أساسية خفيفة - مش محتاجين CUDA/GPU لأن الموديل بقى على Hugging Face API
FROM python:3.11-slim

# تثبيت أدوات أساسية
RUN apt-get update -y && \
    apt-get install -y python3-pip python3-dev curl wget build-essential zstd

# تثبيت SQLite3 من المصدر
RUN wget https://www.sqlite.org/2023/sqlite-autoconf-3410200.tar.gz && \
    tar -xvf sqlite-autoconf-3410200.tar.gz && \
    cd sqlite-autoconf-3410200 && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -rf sqlite-autoconf-3410200 sqlite-autoconf-3410200.tar.gz

# التأكد من تثبيت SQLite3
RUN sqlite3 --version

# نسخ ملفات المشروع
COPY . /src
WORKDIR /src

# تثبيت مكتبات بايثون - torch نسخة CPU الخفيفة أولاً
RUN pip3 install torch --index-url https://download.pytorch.org/whl/cpu && \
    pip3 install -r requirements.txt --default-timeout=1000 --no-cache-dir

# تثبيت Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# فتح البورت
EXPOSE 5000

# تشغيل Ollama وStreamlit مع بعض
COPY start_services.sh /src/start_services.sh
RUN chmod +x /src/start_services.sh
CMD ["/src/start_services.sh"]