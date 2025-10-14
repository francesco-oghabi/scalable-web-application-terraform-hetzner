# Script Video: Deploy Infrastruttura Cloud con Terraform su Hetzner
**Durata totale: 2 minuti (120 secondi)**
**Target: Developer, DevOps, Cloud Engineers**

---

## 🎬 SCENA 1: INTRO (0:00 - 0:15) - 15 secondi

### VISUAL
- Avatar professionale in ambiente tech/ufficio moderno
- Background: sfondo neutro o monitor con codice
- Lower third: "Francesco Oghabi - DevOps Engineer"

### NARRAZIONE (40 parole)
"Ciao! Ti sei mai chiesto come deployare un'infrastruttura cloud completa, sicura e scalabile in meno di 15 minuti? Oggi ti mostro come ho automatizzato il deploy di sei server su Hetzner Cloud usando Terraform. Partiamo!"

### NOTE PRODUZIONE
- Tono: energico, professionale
- Musica background: tech/corporate leggera (20% volume)

---

## 🏗️ SCENA 2: ARCHITETTURA (0:15 - 0:45) - 30 secondi

### VISUAL
- Animazione diagramma architettura (fade-in dei componenti)
- Mostra progressivamente:
  1. Cloud Hetzner + rete privata 10.0.0.0/16
  2. Bastion host con IP pubblico
  3. Server privati: MariaDB, PHP-Nginx, OpenSearch, Redis, RabbitMQ
  4. Frecce connessioni (private network)
- Highlight "NO PUBLIC IP" sui server privati (testo rosso)

### NARRAZIONE (75 parole)
"L'architettura è pensata per la massima sicurezza. Abbiamo una rete privata completamente isolata con cinque server applicativi: un database MariaDB, un application server PHP-Nginx, OpenSearch per la ricerca full-text, Redis per il caching, e RabbitMQ per le code messaggi.

L'accesso avviene tramite un bastion host che funge anche da gateway NAT e DNS server interno. Zero esposizione pubblica: massima sicurezza!"

### NOTE PRODUZIONE
- Animazione: 2 secondi per componente
- Zoom su "10.0.0.0/16" network
- Icon highlight: lucchetto per "security"

---

## 💻 SCENA 3: DEMO DEPLOY (0:45 - 1:35) - 50 secondi

### VISUAL - PARTE 1: Configurazione (10s)
- Screen recording: editor di testo (VS Code/terminal)
- Mostra file `terraform.tfvars` con highlights
- Blur/pixelate sulle password (effetto "censura")

### NARRAZIONE PARTE 1 (25 parole)
"Prima configuriamo le variabili: token API Hetzner, tipo di server, e credenziali. Tutto è parametrizzato tramite Terraform variables."

### VISUAL - PARTE 2: Comandi Terraform (40s)
- Screen recording: terminale con font grande (Monaco/Fira Code)
- Mostra comandi in sequenza con output colorato
- Time-lapse del terraform apply (velocizzato 4x)
- Mostra output:
  ```
  $ terraform init
  Initializing provider plugins...

  $ terraform plan
  Plan: 12 to add, 0 to change, 0 to destroy

  $ terraform apply --auto-approve
  [OUTPUT SCROLLING - VELOCIZZATO]

  Apply complete! Resources: 12 added, 0 changed, 0 destroyed.

  Outputs:
  bastion_public_ip = "X.X.X.X"
  database_private_ip = "10.0.0.4"
  ```
- Overlay timer: "~12 minuti" (accelerato visivamente)

### NARRAZIONE PARTE 2 (95 parole)
"Inizializziamo Terraform, che scarica i provider necessari. Poi eseguiamo plan per vedere cosa verrà creato: 12 risorse tra server, network, route e chiavi SSH.

Lanciamo apply: Terraform crea prima la rete privata, poi il bastion host con configurazione NAT e DNS. Aspetta che il cloud-init completi l'inizializzazione, e infine deploya in parallelo tutti i server privati.

Ogni server viene configurato automaticamente: Docker, servizi containerizzati, Netdata per il monitoring, tutto completamente automatizzato."

### NOTE PRODUZIONE
- Terminal theme: dark (Dracula/Nord)
- Font size: 18-20pt per leggibilità
- Velocizzazione: 4x durante terraform apply
- Highlight: comandi principali (terraform init/plan/apply)

---

## ✅ SCENA 4: RISULTATI E TEST (1:35 - 1:50) - 15 secondi

### VISUAL
- Split screen (2 panel):
  - Sinistra: terminale con SSH login
  - Destra: browser con Netdata dashboard
- Comandi mostrati:
  ```bash
  $ ssh root@<bastion-ip>
  # Connected!

  $ ssh -J root@<bastion-ip> root@10.0.0.4
  # Access to private database server

  $ docker ps
  CONTAINER ID   IMAGE     STATUS
  abc123         mariadb   Up 5 minutes
  ```
- Browser: Netdata dashboard con grafici colorati

### NARRAZIONE (40 parole)
"E siamo online! Mi collego al bastion host, e da lì posso accedere a tutti i server privati tramite SSH jump. Netdata mi dà visibilità completa su CPU, memoria, network: tutto monitorato in tempo reale."

### NOTE PRODUZIONE
- Split screen 50/50
- Transizione smooth tra terminal e browser
- Mostra grafici Netdata in movimento (real-time)

---

## 🎯 SCENA 5: OUTRO E CTA (1:50 - 2:00) - 10 secondi

### VISUAL
- Ritorno ad avatar
- Animazione: logo/link GitHub in overlay (fade-in)
- Testo su schermo:
  ```
  📦 GitHub: github.com/francesco-oghabi/hetzner-server-terraform
  📚 README completo con istruzioni
  🔧 Moduli riusabili
  ```

### NARRAZIONE (25 parole)
"Il codice completo è su GitHub con documentazione dettagliata. Lascia una stella se ti è piaciuto, e seguimi per altri tutorial su DevOps e Cloud!"

### NOTE PRODUZIONE
- Musica crescendo finale
- Animazione: "Like & Subscribe" (subtle, non invadente)
- Fade out finale

---

## 📊 STATISTICHE SCRIPT

**Parole totali**: ~300 parole
**Velocità media**: 150 parole/minuto (ritmo professionale italiano)
**Scene**: 5
**Transizioni**: 4
**Screen recordings necessari**: 2 (editor + terminal)

---

## 🎨 ASSETS NECESSARI

### Da Preparare:
1. **Diagramma architettura** (PNG/SVG)
   - Export da README o crea con draw.io
   - Elementi separati per animazione

2. **Screen recording 1**: Configurazione file
   - Durata: 10 secondi
   - File: terraform.tfvars (blur password)

3. **Screen recording 2**: Deploy completo
   - Durata: 40 secondi (velocizzato da 12 minuti reali)
   - Comandi: init, plan, apply

4. **Screen recording 3**: SSH + Netdata
   - Durata: 15 secondi
   - Split screen

### Musica:
- **Intro/Outro**: energica, tech (Epidemic Sound: "Digital Dreams")
- **Background**: corporate soft (15-20% volume)
- Fade out finale

---

## 🎙️ NOTE PER AI VOICE

### Parametri Voce:
- **Lingua**: Italiano
- **Tono**: Professionale, energico ma non eccessivo
- **Velocità**: 1.0x (normale)
- **Pause**:
  - Dopo domande: 0.5s
  - Tra concetti: 0.3s
  - Fine sezione: 0.8s

### Enfasi Vocale:
- **Forte**: "15 minuti", "Zero esposizione pubblica", "completamente automatizzato"
- **Normale**: descrizioni tecniche
- **Rallentare**: nomi tool (Terraform, MariaDB, OpenSearch)

---

## 🛠️ ISTRUZIONI PER L'AI VIDEO

### Se usi HeyGen/Synthesia:
```
1. Upload questo script nella sezione "Script"
2. Scegli avatar: professionale, maschio 30-40 anni
3. Voce: italiana maschile professionale
4. Aggiungi scene seguendo il timing indicato
5. Upload assets (diagram, screen recordings)
6. Sync visuals con narrazione usando timing indicato
7. Aggiungi musica background e lower thirds
8. Export in 1080p MP4
```

### Prompts per Visual AI (se necessario):
- Scena 1: "Professional IT engineer in modern office, tech background, confident pose"
- Scena 2: "Animated cloud infrastructure diagram, Hetzner logo, network topology with servers"

---

## ✅ CHECKLIST PRE-PRODUZIONE

- [ ] Script revisionato e timing verificato
- [ ] Assets grafici preparati (diagramma architettura)
- [ ] Screen recordings registrati (3 clip)
- [ ] Musica selezionata e scaricata
- [ ] Account piattaforma AI setup (HeyGen/Synthesia)
- [ ] Avatar e voce AI testati
- [ ] Link GitHub verificato funzionante
- [ ] Export settings configurati (1080p, 60fps)

---

**Script versione**: 1.0
**Data**: 2025-10-10
**Autore**: Claude Code + Francesco Oghabi
**Durata target**: 120 secondi ±5s
**Formato output**: MP4 1080p, 30-60fps
