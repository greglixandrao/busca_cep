from pydantic import BaseModel, Field
from typing import Optional


class CEPRequest(BaseModel):
    """Modelo para requisição de CEP"""
    cep: str = Field(..., description="CEP no formato 12345-678 ou 12345678", min_length=8, max_length=9)


class CEPResponse(BaseModel):
    """Modelo para resposta de CEP baseado na API do ViaCEP"""
    cep: str = Field(..., description="CEP formatado")
    logradouro: str = Field(..., description="Nome da rua/avenida")
    complemento: Optional[str] = Field(None, description="Complemento do endereço")
    bairro: str = Field(..., description="Nome do bairro")
    localidade: str = Field(..., description="Nome da cidade")
    uf: str = Field(..., description="Sigla do estado")


class ErrorResponse(BaseModel):
    """Modelo para resposta de erro"""
    error: str = Field(..., description="Mensagem de erro")
    detail: Optional[str] = Field(None, description="Detalhes do erro")
