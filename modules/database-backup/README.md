# Database Backup Service Module

Questo modulo Terraform configura un servizio sicuro di backup remoto per i database MariaDB in esecuzione su Docker nella rete privata.

## Caratteristiche

- ✅ **Accesso Sicuro**: Utente dedicato con accesso SSH limitato e solo lettura sui database
- ✅ **SSH Forced Command**: L'utente può SOLO eseguire il dump, nessun accesso alla shell
- ✅ **Validazione Input**: Protezione contro SQL injection e comandi dannosi
- ✅ **Logging Completo**: Tutti gli accessi vengono registrati per audit
- ✅ **Flessibile**: Supporta chiave SSH fornita dall'utente o generazione automatica
- ✅ **Controllo Accessi**: Possibilità di limitare i database accessibili

## Architettura

```
┌─────────────────┐
│  Utente Esterno │
└────────┬────────┘
         │ SSH (porta 22)
         │ Chiave privata
         ▼
┌─────────────────────────────┐
│     Bastion Host            │
│  (Public IP: X.X.X.X)       │
│                             │
│  Utente: dbbackup           │
│  Forced Command:            │
│  /usr/local/bin/db-dump.sh  │
└────────┬────────────────────┘
         │ MySQL (porta 3306)
         │ User: readonly
         ▼
┌─────────────────────────────┐
│   Database Server           │
│  (Private: 10.0.0.4)        │
│                             │
│  MariaDB in Docker          │
│  Utente readonly con        │
│  permessi SELECT only       │
└─────────────────────────────┘
```

## Requisiti

- Bastion host configurato con accesso SSH
- Database MariaDB con utente readonly configurato
- Terraform >= 1.0

## Variabili

| Variabile | Descrizione | Default | Required |
|-----------|-------------|---------|----------|
| `bastion_public_ip` | IP pubblico del bastion host | - | Sì |
| `database_private_ip` | IP privato del server database | `10.0.0.4` | No |
| `mariadb_readonly_user` | Utente MySQL readonly | `readonly` | No |
| `mariadb_readonly_password` | Password utente readonly | - | Sì |
| `backup_user_public_key` | Chiave SSH pubblica (opzionale) | `""` | No |
| `allowed_databases` | Lista database consentiti | `[]` (tutti) | No |

## Output

| Output | Descrizione | Sensitive |
|--------|-------------|-----------|
| `backup_user_private_key` | Chiave privata SSH generata | Sì |
| `backup_user_public_key` | Chiave pubblica SSH | No |
| `connection_command` | Comando esempio per connettersi | No |
| `usage_instructions` | Istruzioni complete d'uso | No |

## Utilizzo

### Configurazione Base

Nel tuo `main.tf`:

```hcl
module "database_backup" {
  source = "./modules/database-backup"

  bastion_public_ip          = hcloud_server.bastion.ipv4_address
  database_private_ip        = var.database_static_ip
  mariadb_readonly_user      = var.mariadb_readonly_user
  mariadb_readonly_password  = var.mariadb_readonly_password
  backup_user_public_key     = var.backup_user_public_key
  allowed_databases          = var.allowed_databases

  depends_on = [
    null_resource.wait_for_bastion_cloud_init,
    module.database
  ]
}
```

### Configurazione con Chiave Generata da Terraform

```hcl
module "database_backup" {
  source = "./modules/database-backup"

  bastion_public_ip          = hcloud_server.bastion.ipv4_address
  mariadb_readonly_password  = var.mariadb_readonly_password
  # backup_user_public_key non specificato = chiave generata automaticamente
}
```

### Configurazione con Chiave Esistente

```hcl
module "database_backup" {
  source = "./modules/database-backup"

  bastion_public_ip          = hcloud_server.bastion.ipv4_address
  mariadb_readonly_password  = var.mariadb_readonly_password
  backup_user_public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAA... user@host"
}
```

### Limitare i Database Accessibili

```hcl
module "database_backup" {
  source = "./modules/database-backup"

  bastion_public_ip          = hcloud_server.bastion.ipv4_address
  mariadb_readonly_password  = var.mariadb_readonly_password
  allowed_databases          = ["production_db", "staging_db"]
  # Solo questi database saranno accessibili
}
```

## Comandi per l'Utente Esterno

### 1. Salvare la Chiave Privata

Dopo aver eseguito `terraform apply`:

```bash
# Salvare la chiave privata generata
terraform output -raw database_backup_private_key > ~/.ssh/dbbackup_key

# Impostare i permessi corretti
chmod 600 ~/.ssh/dbbackup_key
```

### 2. Eseguire un Backup

```bash
# Backup semplice
ssh -i ~/.ssh/dbbackup_key dbbackup@<BASTION_IP> "nome_database" > dump.sql

# Backup compresso
ssh -i ~/.ssh/dbbackup_key dbbackup@<BASTION_IP> "nome_database" | gzip > dump.sql.gz

# Backup con bzip2 (compressione maggiore)
ssh -i ~/.ssh/dbbackup_key dbbackup@<BASTION_IP> "nome_database" | bzip2 > dump.sql.bz2
```

### 3. Listar Database Disponibili

```bash
ssh -i ~/.ssh/dbbackup_key dbbackup@<BASTION_IP> "--list-databases"
```

### 4. Backup Automatico con Cron

Crea uno script di backup:

```bash
#!/bin/bash
# backup-database.sh

BACKUP_DIR="/backup/databases"
DATE=$(date +%Y%m%d_%H%M%S)
BASTION_IP="X.X.X.X"
DATABASE="production_db"

mkdir -p "$BACKUP_DIR"

ssh -i ~/.ssh/dbbackup_key dbbackup@$BASTION_IP "$DATABASE" | \
    gzip > "$BACKUP_DIR/${DATABASE}_${DATE}.sql.gz"

# Elimina backup più vecchi di 30 giorni
find "$BACKUP_DIR" -name "${DATABASE}_*.sql.gz" -mtime +30 -delete

echo "Backup completato: ${DATABASE}_${DATE}.sql.gz"
```

Aggiungi al crontab:

```bash
# Backup giornaliero alle 2:00 AM
0 2 * * * /path/to/backup-database.sh >> /var/log/db-backup.log 2>&1
```

## Sicurezza

### Misure Implementate

1. **Utente Dedicato**: L'utente `dbbackup` ha:
   - Nessuna shell interattiva (`/usr/sbin/nologin`)
   - Home directory isolata (`/home/dbbackup`)
   - Solo accesso tramite chiave SSH

2. **SSH Forced Command**:
   - L'utente può SOLO eseguire `/usr/local/bin/db-dump.sh`
   - Nessun port forwarding, X11 forwarding, o agent forwarding
   - Nessun accesso PTY (pseudo-terminal)

3. **Validazione Input**:
   - Solo caratteri alfanumerici, underscore e trattini nei nomi database
   - Protezione contro SQL injection
   - Controllo esistenza database prima del dump

4. **Permessi MySQL**:
   - Utente readonly con solo permessi `SELECT`, `PROCESS`, `REPLICATION CLIENT`
   - Nessun permesso di scrittura o modifica

5. **Logging**:
   - Tutti gli accessi registrati in `/var/log/dbbackup/access.log`
   - Include timestamp, IP client, database, e azione

### Configurazione Firewall Consigliata

Sul bastion host, limita l'accesso SSH solo da IP fidati:

```bash
# Permettere solo da IP specifici
ufw allow from <TRUSTED_IP> to any port 22 proto tcp

# O limitare per l'utente dbbackup usando Match in sshd_config
Match User dbbackup
    AllowUsers dbbackup
    PermitOpen none
    X11Forwarding no
    AllowTcpForwarding no
```

## Logging e Monitoring

### Visualizzare i Log

```bash
# Sul bastion host
ssh root@<BASTION_IP>
tail -f /var/log/dbbackup/access.log
```

### Formato Log

```
2025-01-15 14:30:45 - IP: 203.0.113.25 - Database: production_db - Action: SUCCESS
2025-01-15 14:30:50 - IP: 203.0.113.25 - Database: production_db - Action: DUMP_COMPLETED
2025-01-15 14:35:12 - IP: 198.51.100.42 - Database: invalid_db - Action: REJECTED - Database not found
```

### Monitoring con Script

```bash
#!/bin/bash
# check-backup-logs.sh

LOG_FILE="/var/log/dbbackup/access.log"
ALERT_EMAIL="admin@example.com"

# Controlla fallimenti nell'ultima ora
FAILURES=$(grep -c "REJECTED\|FAILED" <(tail -n 1000 "$LOG_FILE" | grep "$(date +%Y-%m-%d)"))

if [ "$FAILURES" -gt 5 ]; then
    echo "ALERT: $FAILURES backup failures in the last hour" | \
        mail -s "Database Backup Alert" "$ALERT_EMAIL"
fi
```

## Troubleshooting

### Problema: "Permission denied (publickey)"

**Soluzione**: Verifica i permessi della chiave:

```bash
chmod 600 ~/.ssh/dbbackup_key
ls -la ~/.ssh/dbbackup_key  # Deve mostrare -rw-------
```

### Problema: "Database not found"

**Soluzione**: Lista i database disponibili:

```bash
ssh -i ~/.ssh/dbbackup_key dbbackup@<BASTION_IP> "--list-databases"
```

### Problema: "Database not in allowed list"

**Soluzione**: Il database richiesto non è nella lista `allowed_databases`. Contatta l'amministratore o aggiorna la configurazione Terraform.

### Problema: Backup molto lento

**Soluzione**: Il dump è in formato SQL non compresso. Comprimi durante il trasferimento:

```bash
# Compressione al volo
ssh -i ~/.ssh/dbbackup_key dbbackup@<BASTION_IP> "db_name" | pv | gzip > dump.sql.gz
```

## Limitazioni

1. **Solo MariaDB/MySQL**: Il modulo supporta solo database MariaDB/MySQL
2. **Single-threaded**: I dump sono single-threaded (usa `mysqldump`)
3. **Nessun Restore**: Il modulo gestisce solo backup, non restore (va fatto manualmente)
4. **Nessuna Rotazione**: La rotazione dei backup va implementata dall'utente

## Estensioni Future

Possibili miglioramenti:

- [ ] Supporto per backup incrementali
- [ ] Compressione automatica sul bastion
- [ ] Upload automatico su S3/cloud storage
- [ ] Notifiche via email/Slack
- [ ] Dashboard web per gestire backup
- [ ] Supporto per altri database (PostgreSQL, MongoDB)

## Licenza

Questo modulo fa parte del progetto hetzner-server-terraform.

## Supporto

Per problemi o domande, apri una issue nel repository del progetto.