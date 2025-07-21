# comment\_analysis

**Aplicação API Rails para análise, tradução e classificação de comentários de usuários**

## Repositório Git

Este repositório contém todo o código-fonte da aplicação. Para executar localmente, siga as instruções de **Setup**.

## Setup Simples

1. **Clonar repositório**

   ```bash
   git clone https://github.com/janillson/comment_analysis.git
   cd comment_analysis
   ```
2. **Instalar dependências**

   ```bash
   bundle install
   ```
3. **Configurar variáveis de ambiente** (arquivo `.env.development` na raiz):

   ```ini
   REDIS_URL=redis://localhost:6379/0
   ```
4. **Banco de dados**

   ```bash
   rails db:create db:migrate
   ```
5. **Iniciar serviços**

   * Sidekiq
   * Rails server

   ```bash
   bin/dev
   ```



> OBS: Precisa do `Redis` e `PostgreSQL` rodando local

## Arquitetura

* **Ruby** 3.3.2
* **Rails** \~> 7.0.8 (>= 7.0.8.4)
* **Banco de dados**: PostgreSQL (gem `pg`)
* **Job Queue**: Sidekiq (gem `sidekiq`) com Redis (gem `redis`)
* **State Machine**: `aasm` para gerenciar estados (`created → processing → approved/reject`)
* **HTTP Cliente**: `httparty` para chamadas externas
* **Tradução**: `google-translate-free` (API não oficial do Google Translate)
* **Serviços**:

  * `UserAnalysisService` (orquestra toda a análise: importação, enfileiramento e métricas)
  * `JsonPlaceholderImportService` (importa usuário, posts e comentários da JSONPlaceholder)
  * `ProcessCommentJob` (executa tradução e classificação de cada comentário)
  * `CalculateUserMetricsJob` & `CalculateGroupMetricsJob` (recomputam métricas de usuário e grupo de forma assíncrona)
  * `UserResponseBuilderService` (constrói e formata o JSON de resposta final)
  * `ReprocessAllUsersJob` (Reculcula ao criar/deletar uma nova palavra-chave)

## Métricas Disponíveis

Este projeto fornece dois conjuntos de métricas principais: **Métricas de Usuário** e **Métricas de Grupo**. Elas são calculadas automaticamente ao chamar o endpoint principal e retornadas no formato JSON.

---

### 1. Métricas de Usuário (`user_metrics`)

Representam o comportamento de um único usuário. Estão disponíveis os campos:

* **total\_comments** (`Integer`)
  Número total de comentários feitos pelo usuário.

* **approved\_comments** (`Integer`)
  Quantidade de comentários aprovados pelo sistema.

* **rejected\_comments** (`Integer`)
  Quantidade de comentários rejeitados pelo sistema.

* **approval\_rate** (`Float`)
  Percentual de comentários aprovados.

  O valor é retornado arredondado com duas casas decimais.

* **average\_comment\_length** (`Float`)
  Comprimento médio, em caracteres, dos comentários do usuário. Arredondado com duas casas decimais.

* **median\_comment\_length** (`Float`)
  Mediana do comprimento (em caracteres) dos comentários. Útil para entender o comportamento típico sem influência de valores extremos.

* **std\_dev\_comment\_length** (`Float`)
  Desvio padrão do comprimento dos comentários. Indica a variabilidade nos tamanhos de comentários.

---

### 2. Métricas de Grupo (`group_metrics`)

Agregam o comportamento de todos os usuários no sistema. Os campos disponíveis são:

* **total\_users** (`Integer`)
  Número total de usuários cadastrados.

* **total\_comments** (`Integer`)
  Soma de todos os comentários feitos por todos os usuários.

* **overall\_approval\_rate** (`Float`)
  Percentual de aprovação dos comentários de todo o grupo.

  Retornado com duas casas decimais.

* **average\_comments\_per\_user** (`Float`)
  Média de comentários por usuário. Arredondado com duas casas decimais.

* **median\_comments\_per\_user** (`Float`)
  Mediana de comentários por usuário. Ajuda a identificar o comportamento típico sem outliers.

* **std\_dev\_comments\_per\_user** (`Float`)
  Desvio padrão da quantidade de comentários por usuário, mostrando a dispersão entre os usuários.

## Endpoints e Postman Collection

1. **Importação e Análise**

   ```http
   POST /api/v1/users/analyze
   Content-Type: application/json

   { "username": "Bret" }
   ```

   * Dispara jobs em lote (importação + tradução + classificação)
   * Retorna
    ```json
      {
        "user": {
            "username": "Bret",
            "name": "Leanne Graham",
            "email": "Sincere@april.biz"
        },
        "user_metrics": {
            "total_comments": 50,
            "approved_comments": 15,
            "rejected_comments": 35,
            "approval_rate": 30.0,
            "average_comment_length": 143.86,
            "median_comment_length": 145.5,
            "std_dev_comment_length": 24.41
        },
        "group_metrics": {
            "total_users": 3,
            "total_comments": 150,
            "overall_approval_rate": 26.0,
            "average_comments_per_user": 50.0,
            "median_comments_per_user": 50.0,
            "std_dev_comments_per_user": 0.0
        }
      }
   ```

2. **Status do Job**

   ```http
   GET /api/v1/progress
   ```

   * Exemplo:

     ```json
     [
      {
        "queue": "default",
        "class": "ProcessCommentJob",
        "args": [
            {
                "comment_id": 3
            }
        ],
        "run_at": "2025-07-21T17:22:44.000-03:00"
      }
     ]
     ```

3. **CRUD de Palavras‑Chave**

   ```http
   GET    /api/v1/keywords        { "keywords": ["Olá"] }
   POST   /api/v1/keywords        { "message": "Palavra-chave adicionada com sucesso" }
   DELETE /api/v1/keywords/:word  { "message": "Palavra-chave removida com sucesso" }
   ```

   * Toda alteração reinicia reprocessamento das métricas em cache exceto o index.

> **Coleção Postman**: [Postman Collection](https://janillson-2807313.postman.co/workspace/Jan's-Workspace~d93c96c8-46f0-4d99-83bf-f3d58d608b44/collection/46946214-e123389a-fd14-495e-a7af-42bfb82614e7?action=share&creator=46946214)
