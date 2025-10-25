Resumo dos Endpoints
Funcionários

GET /api/employees - Listar todos os funcionários
GET /api/employees/:id - Obter funcionário por ID
GET /api/employees/code/:code - Obter funcionário por código interno
POST /api/employees - Criar funcionário
PUT /api/employees/:id - Atualizar funcionário
DELETE /api/employees/:id - Excluir funcionário

Registro de Ponto

GET /api/attendance - Obter registros de ponto (com filtros)
POST /api/attendance/register - Registrar ponto (entrada ou saída)
PUT /api/attendance/:id - Atualizar registro de ponto
DELETE /api/attendance/:id - Excluir registro de ponto

Horário de Trabalho

GET /api/work-schedule - Obter configuração de horário
PUT /api/work-schedule - Atualizar configuração de horário

Departamentos

GET /api/departments - Listar todos os departamentos
GET /api/departments/:id - Obter departamento por ID
POST /api/departments - Criar departamento
PUT /api/departments/:id - Atualizar departamento
DELETE /api/departments/:id - Excluir departamento