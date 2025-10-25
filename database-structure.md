# Estrutura da Base de Dados - Controle de Ponto

## Visão Geral
Este documento descreve a estrutura completa da base de dados utilizada no aplicativo de controle de ponto, que utiliza **Supabase** (PostgreSQL) como backend.

## Tabelas Principais

### 1. **employees** (Funcionários)
```sql
CREATE TABLE employees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR NOT NULL,
  position VARCHAR NOT NULL,
  department VARCHAR NOT NULL,
  internal_code VARCHAR UNIQUE NOT NULL,
  qr_code VARCHAR,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
  synced BOOLEAN,
  cached_at TIMESTAMP WITH TIME ZONE
);
```

**Descrição dos Campos:**
- `id`: Identificador único do funcionário (UUID)
- `name`: Nome completo do funcionário
- `position`: Cargo/função
- `department`: Departamento/setor
- `internal_code`: Código interno único (formato: AEM + 3 dígitos)
- `qr_code`: Código QR para identificação (atualmente usa o internal_code)
- `created_at`: Data e hora de criação do registro
- `synced`: Flag indicando se o registro foi sincronizado
- `cached_at`: Data do último cache local

### 2. **attendance** (Presenças)
```sql
CREATE TABLE attendance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id UUID NOT NULL REFERENCES employees(id),
  date DATE NOT NULL,
  check_in TIME,
  check_out TIME,
  late_minutes INTEGER DEFAULT 0,
  status VARCHAR NOT NULL,
  observations TEXT,
  auth_method VARCHAR NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
  synced BOOLEAN,
  cached_at TIMESTAMP WITH TIME ZONE
);
```

**Descrição dos Campos:**
- `id`: Identificador único do registro de presença
- `employee_id`: Referência ao funcionário (chave estrangeira)
- `date`: Data da presença
- `check_in`: Horário de entrada (formato HH:MM)
- `check_out`: Horário de saída (formato HH:MM)
- `late_minutes`: Quantidade de minutos de atraso
- `status`: Status da presença
  - 'Presente': Funcionário presente
  - 'Atrasado': Entrada com atraso
  - 'Ausente': Não registrou presença
  - 'Em exercício': Em atividade
  - 'Saída': Já fez checkout
  - 'Justificado': Falta justificada
- `observations`: Observações adicionais
- `auth_method`: Método de autenticação usado
  - 'code': Código interno
  - 'face': Reconhecimento facial
  - 'fingerprint': Biometria
  - 'qr': Código QR
- `created_at`: Data e hora de criação do registro
- `synced`: Flag de sincronização
- `cached_at`: Data do cache

**Índices de Performance:**
- `idx_attendance_employee_id` em `employee_id`
- `idx_attendance_date` em `date`

### 3. **work_schedule** (Horário de Trabalho)
```sql
CREATE TABLE work_schedule (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  work_days INTEGER[] NOT NULL,
  late_tolerance INTEGER DEFAULT 15,
  daily_hours DECIMAL(3,1) DEFAULT 8.0,
  auto_checkout BOOLEAN DEFAULT false,
  require_location BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
  synced BOOLEAN,
  cached_at TIMESTAMP WITH TIME ZONE
);
```

**Descrição dos Campos:**
- `id`: Identificador único da configuração de horário
- `start_time`: Horário de início da jornada (formato HH:MM)
- `end_time`: Horário de fim da jornada (formato HH:MM)
- `work_days`: Dias da semana de trabalho (array de inteiros)
  - 0 = Domingo, 1 = Segunda, 2 = Terça, 3 = Quarta, 4 = Quinta, 5 = Sexta, 6 = Sábado
- `late_tolerance`: Tolerância de atraso em minutos (padrão: 15)
- `daily_hours`: Carga horária diária em horas (padrão: 8.0)
- `auto_checkout`: Se deve marcar saída automaticamente ao fim do expediente
- `require_location`: Se deve verificar localização do funcionário
- `created_at`: Data e hora de criação
- `synced`: Flag de sincronização
- `cached_at`: Data do cache

### 4. **departments** (Departamentos)
```sql
CREATE TABLE departments (
  id SERIAL PRIMARY KEY,
  name VARCHAR NOT NULL
);
```

**Descrição dos Campos:**
- `id`: Identificador único do departamento (auto-incremento)
- `name`: Nome do departamento

## Relacionamentos

```
employees (1) ──── (N) attendance
employees (1) ──── (N) departments (via campo department - relacionamento por nome)
work_schedule (1) ──── (1) global (sempre um registro ativo)
```

## Políticas de Segurança (RLS - Row Level Security)

Todas as tabelas têm **Row Level Security** habilitado, permitindo acesso completo para usuários autenticados:

```sql
-- Política aplicada a todas as tabelas
CREATE POLICY "Allow authenticated users full access"
ON [table_name]
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);
```

## Migrações Aplicadas

### Migração 002_update_tables.sql
- Converte `employee_id` para tipo UUID
- Converte `date` para tipo DATE
- Converte `time_in` para tipo TIME
- Adiciona valor padrão 0 para `late_minutes`
- Adiciona valor padrão para `created_at`
- Cria índices de performance
- Habilita RLS

### Migração add_schedule_fields.sql
- Adiciona campos de tolerância e configuração à tabela `work_schedule`
- Adiciona comentários explicativos
- Atualiza registros existentes com valores padrão

## Funcionalidades Especiais

### 1. **Geração de Códigos Únicos**
- Funcionários recebem códigos internos no formato `AEMXXX` (onde XXX são 3 dígitos aleatórios)
- Sistema garante unicidade dos códigos

### 2. **Suporte Offline**
- Campos `synced` e `cached_at` para controle de sincronização
- Aplicativo funciona parcialmente offline

### 3. **Autenticação Múltipla**
- Suporte a diferentes métodos de autenticação
- QR Code baseado no código interno

### 4. **Cálculo Automático de Atrasos**
- Sistema calcula minutos de atraso baseado no horário de entrada vs horário configurado
- Tolerância configurável por departamento

## Considerações Técnicas

- **Banco**: Supabase (PostgreSQL)
- **Autenticação**: Baseada em usuários do Supabase Auth
- **Timezone**: UTC para todos os timestamps
- **Encoding**: UTF-8
- **RLS**: Segurança a nível de linha habilitada
- **Índices**: Otimizados para consultas frequentes

## Queries Comuns

### Buscar funcionários com presenças do dia
```sql
SELECT e.name, a.check_in, a.check_out, a.status
FROM employees e
LEFT JOIN attendance a ON e.id = a.employee_id
WHERE a.date = CURRENT_DATE;
```

### Relatório mensal de presenças
```sql
SELECT e.name, COUNT(a.*) as total_days, AVG(a.late_minutes) as avg_late
FROM employees e
LEFT JOIN attendance a ON e.id = a.employee_id
WHERE a.date >= '2024-01-01' AND a.date <= '2024-01-31'
GROUP BY e.id, e.name;
```

---

*Última atualização: Outubro 2025*
*Baseado na análise do código fonte do aplicativo*</content>
<filePath>/Users/joaomuchunja/controle-ponto/database-structure.md