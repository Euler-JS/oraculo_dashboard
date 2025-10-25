# Processo de Marcação de Presença

## Visão Geral
Este documento explica detalhadamente como funciona o sistema de marcação de presença no aplicativo de controle de ponto, incluindo os dados necessários, validações e processo de atualização de registros.

## Métodos de Autenticação Disponíveis

O sistema suporta múltiplos métodos de autenticação para registro de presença:

### 1. **Código Interno (Code)**
- **Formato**: `AEMXXX` (onde XXX são 3 dígitos)
- **Exemplo**: `AEM123`, `AEM456`
- **Uso**: Digitação manual do código

### 2. **Código QR (QR)**
- **Conteúdo**: Mesmo código interno do funcionário
- **Formato**: `AEMXXX`
- **Uso**: Leitura via câmera do dispositivo

### 3. **Reconhecimento Facial (Face)**
- **Status**: Implementado mas não totalmente funcional
- **Uso**: Reconhecimento biométrico

### 4. **Biometria (Fingerprint)**
- **Status**: Implementado mas não totalmente funcional
- **Uso**: Leitura de impressão digital

## Dados Necessários para Marcação de Presença

### Dados do Funcionário
```typescript
interface Employee {
  id: string;              // UUID único
  name: string;            // Nome completo
  position: string;        // Cargo
  department: string;      // Departamento
  internal_code: string;   // Código único (AEMXXX)
  qr_code: string;         // Código QR (igual ao internal_code)
}
```

### Dados da Presença
```typescript
interface Attendance {
  id?: string;                    // UUID (gerado automaticamente)
  employee_id: string;           // Referência ao funcionário
  date: string;                  // Data (YYYY-MM-DD)
  check_in?: string;            // Horário de entrada (HH:MM)
  check_out?: string;           // Horário de saída (HH:MM)
  late_minutes?: number;        // Minutos de atraso
  status: AttendanceStatus;     // Status da presença
  observations?: string;        // Observações
  auth_method: AuthMethod;      // Método de autenticação usado
  created_at?: Date;            // Data/hora de criação
}
```

### Configuração de Horário de Trabalho
```typescript
interface WorkSchedule {
  start_time: string;           // Horário de início (HH:MM)
  end_time: string;             // Horário de fim (HH:MM)
  work_days: number[];          // Dias da semana [1,2,3,4,5] (segunda a sexta)
  late_tolerance?: number;      // Tolerância de atraso (minutos)
  daily_hours?: number;         // Carga horária diária
}
```

## Fluxo de Marcação de Presença

### 1. **Validação do Funcionário**
```typescript
// Busca funcionário por código
const employee = await findEmployeeByCode(employeeCode);

// Validações realizadas:
- Funcionário existe no sistema
- Código está correto
- Funcionário está ativo
```

### 2. **Verificação de Registros Existentes**
```typescript
// Busca registro do dia atual
const existingRecord = await supabase
  .from('attendance')
  .select('*')
  .eq('employee_id', employee.id)
  .eq('date', today)
  .single();
```

### 3. **Lógica de Decisão - Entrada vs Saída**

#### **Cenário 1: Primeira Marcação do Dia (Entrada)**
```typescript
if (!existingRecord) {
  // Criar novo registro de entrada
  const attendanceData = {
    employee_id: employee.id,
    date: today,
    check_in: currentTime,                    // Horário atual
    late_minutes: calculateLateMinutes(),     // Cálculo de atraso
    status: determineStatus(lateMinutes),     // 'Presente' ou 'Atrasado'
    auth_method: method,                      // Método usado
    created_at: now
  };
}
```

#### **Cenário 2: Marcação de Saída**
```typescript
else if (!existingRecord.check_out) {
  // Atualizar registro com saída
  const attendanceData = {
    ...existingRecord,
    check_out: currentTime,    // Horário atual
    status: 'Presente'         // Status final
  };
}
```

#### **Cenário 3: Tentativa Duplicada**
```typescript
else {
  // Já registrou entrada E saída hoje
  throw new Error(`${employee.name} já registrou entrada e saída hoje`);
}
```

## Cálculo de Atrasos

### Algoritmo de Cálculo
```typescript
private calculateLateMinutes(timeIn: string, start_time: string): number {
  // Converte horários para minutos
  const [inHour, inMinute] = timeIn.split(':').map(Number);
  const [startHour, startMinute] = start_time.split(':').map(Number);

  const totalInMinutes = inHour * 60 + inMinute;
  const totalStartMinutes = startHour * 60 + startMinute;

  // Retorna diferença positiva (atraso) ou 0
  return Math.max(0, totalInMinutes - totalStartMinutes);
}
```

### Exemplos de Cálculo

| Horário de Entrada | Horário Configurado | Minutos de Atraso | Status |
|-------------------|-------------------|------------------|---------|
| 08:00 | 08:00 | 0 | Presente |
| 08:15 | 08:00 | 15 | Atrasado |
| 07:45 | 08:00 | 0 | Presente |

### Tolerância de Atraso
- **Valor padrão**: 15 minutos
- **Configurável** por departamento
- **Aplicação**: Se atraso ≤ tolerância → Status = 'Presente'

## Processo de Atualização de Registros

### Método de Atualização
```typescript
async updateAttendanceRecord(attendanceId: string, data: Partial<Attendance>): Promise<Attendance> {
  // Apenas online
  if (!this.networkService.isOnline()) {
    throw new Error('Não é possível editar registros no modo offline');
  }

  // Atualizar no Supabase
  const { data: updatedRecord, error } = await this.supabase
    .from('attendance')
    .update(data)
    .eq('id', attendanceId)
    .select(`
      *,
      employee:employees (
        id,
        name,
        internal_code
      )
    `)
    .single();

  return updatedRecord;
}
```

### Campos Editáveis
- `check_in`: Horário de entrada
- `check_out`: Horário de saída
- `late_minutes`: Minutos de atraso (recalculado)
- `status`: Status da presença
- `observations`: Observações
- `auth_method`: Método de autenticação

### Restrições de Edição
- **Modo offline**: Não permite edição
- **Validações**: Mesmas regras de negócio aplicam
- **Auditoria**: Todas as alterações são registradas

## Regras de Validação

### Validações de Entrada
1. **Funcionário existe**: Código deve corresponder a funcionário ativo
2. **Horário válido**: Formato HH:MM válido
3. **Dia de trabalho**: Deve ser dia configurado na semana
4. **Duplicação**: Não permitir múltiplas entradas/saídas no mesmo dia

### Validações de Saída
1. **Entrada prévia**: Deve ter registro de entrada
2. **Horário mínimo**: Saída só permitida após meio-dia (12:00)
3. **Sequência lógica**: Entrada antes da saída

### Validações de Atualização
1. **Conectividade**: Apenas online
2. **Permissões**: Usuário deve ter privilégios de edição
3. **Consistência**: Dados devem manter integridade

## Tratamento de Erros

### Cenários de Erro Comuns

#### 1. **Funcionário Não Encontrado**
```typescript
throw new Error('Funcionário não encontrado. Verifique o código inserido.');
```

#### 2. **Dupla Marcação**
```typescript
throw new Error(`${employee.name} já registrou entrada e saída hoje`);
```

#### 3. **Saída Prematura**
```typescript
throw new Error(`${employee.name}, ainda é muito cedo para registrar saída.`);
```

#### 4. **Modo Offline**
```typescript
throw new Error('Não é possível editar registros no modo offline');
```

## Funcionalidades Especiais

### 1. **Suporte Offline**
- **Leitura**: Cache local permite consulta de dados
- **Escrita**: Apenas sincronização quando online
- **Sincronização**: Dados locais são enviados quando conexão retorna

### 2. **Cálculo Automático de Status**
```typescript
private determineStatus(lateMinutes: number): AttendanceStatus {
  return lateMinutes > 0 ? 'Atrasado' : 'Presente';
}
```

### 3. **Feedback em Tempo Real**
- **Entrada**: "Bom dia [Nome]! Entrada registrada com sucesso às [hora]."
- **Saída**: "Até amanhã [Nome]! Saída registrada com sucesso às [hora]."

### 4. **Histórico Completo**
- **Rastreamento**: Todos os registros mantidos
- **Relatórios**: Consultas por período, funcionário, etc.
- **Auditoria**: Log completo de alterações

## API Endpoints Utilizados

### Marcação de Presença
```typescript
// Registro principal
POST /attendance
{
  employee_id: string,
  date: string,
  check_in?: string,
  check_out?: string,
  auth_method: string
}
```

### Atualização
```typescript
// Edição de registro
PUT /attendance/{id}
{
  check_in?: string,
  check_out?: string,
  observations?: string
}
```

### Consulta
```typescript
// Buscar presenças do mês
GET /attendance?start_date=2024-01-01&end_date=2024-01-31

// Buscar presença específica
GET /attendance/{id}
```

## Considerações Técnicas

### Performance
- **Índices**: `idx_attendance_employee_id`, `idx_attendance_date`
- **Cache**: Dados locais para modo offline
- **Paginação**: Consultas limitadas para performance

### Segurança
- **RLS**: Row Level Security habilitado
- **Autenticação**: Apenas usuários logados
- **Validação**: Dados sanitizados antes da persistência

### Concorrência
- **Transações**: Operações atômicas
- **Locks**: Prevenção de conflitos simultâneos
- **Versionamento**: Controle de versão de registros

---

*Última atualização: Outubro 2025*
*Baseado na implementação do serviço EmployeeService*</content>
<filePath>/Users/joaomuchunja/controle-ponto/attendance-process.md