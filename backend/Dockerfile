# Use Python 3.11 slim como base
FROM python:3.11-slim

# Definir variáveis de ambiente
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app

# Criar usuário não-root para segurança
RUN adduser --disabled-password --gecos '' --uid 1000 appuser

# Definir diretório de trabalho
WORKDIR /app

# Instalar dependências do sistema se necessário
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copiar arquivos de dependências
COPY requirements.txt .

# Instalar dependências Python
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copiar código da aplicação
COPY . .

# Alterar proprietário dos arquivos para o usuário não-root
RUN chown -R appuser:appuser /app

# Mudar para o usuário não-root
USER appuser

# Expor a porta
EXPOSE 8000

# Comando para executar a aplicação
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
