# PGR301 Exam

## Oppgave 1 AWS Lambda
## Oppgave 1A:
### HTTP Endepunkt for Lambda Funksjonen:
    `https://ra9v34knf1.execute-api.eu-west-1.amazonaws.com/Prod/generate-image/`

### Testing med curl:
Her kan du teste enten med 'curl' eller i Postman:  
Husk å skrive noe inne i "prompt" feltet! F.eks: "A man on top of an airplane."

```bash
curl -X POST https://ra9v34knf1.execute-api.eu-west-1.amazonaws.com/Prod/generate-image/ \
-H "Content-Type: application/json" \
-d '{ "prompt": "" }'
```

## Oppgave 1B:
### Lenke til vellykket kjøring av GitHub Actions workflow som har deployet SAM-applikasjonen til aws:
`https://github.com/williamvage123/PGR301-Exam-2024/actions/runs/12022752183/job/33515482927`
    
    
## Oppgave 2: Infrastruktur med Terraform og SQS

### SQS Queue URL
Den opprettede SQS-kø URL-en finnes her:
`https://sqs.eu-west-1.amazonaws.com/244530008913/image-processing-queue-k79`

### GitHub Actions Workflows
1. **Main branch Terraform Apply workflow**
   Lenke til vellykket kjøring av workflow for `terraform apply` på main:
`https://github.com/williamvage123/PGR301-Exam-2024/actions/runs/12022926943/job/33515953028`  

2. **Test branch Terraform Plan workflow**
   Lenke til vellykket kjøring av workflow for `terraform plan` på annen branch:
`https://github.com/williamvage123/PGR301-Exam-2024/actions/runs/12022965283/job/33516055961`

## Oppgave 3: Javaklient og Docker

### Beskrivelse av taggestrategi:
Jeg valgte å kombinere to strategier for tagging. For hver endring blir Docker imaget tagget med både:
 -  Commit SHA: Då får vi en unik indifikator for hver versjon av koden, som gjør at det er enkelt å spore/rulle tilbake til en versjon.
 -  `latest`: Då får vi den nyeste versjonen av imaget som gjør at det blir enkelt å trekke imaget unten å spesifisere en spesifikk versjon.

### Dockerhub image name:
`wiva002/java-sqs-client:latest`


### SQS Queue URL:
`https://sqs.eu-west-1.amazonaws.com/244530008913/image-processing-queue-k79`

### GitHub Actions Workflows:
Lenke til vellykket kjøring av workflow som bygger og publiserer Docker imaget:
`https://github.com/williamvage123/PGR301-Exam-2024/actions/runs/12023106074/job/33516457977`

### Testing av Docker Image:
Bruk følgende kommando for å teste Docker-imaget. Sørg for å fylle ut `AWS_ACCESS_KEY_ID` og `AWS_SECRET_ACCESS_KEY` med dine egne verdier. Du kan også endre teksten i anførselstegn (prompt) til noe annet.
```bash
docker run --rm \
  -e AWS_ACCESS_KEY_ID=<your-access-key-id> \
  -e AWS_SECRET_ACCESS_KEY=<your-secret-access-key> \
  -e SQS_QUEUE_URL="https://sqs.eu-west-1.amazonaws.com/244530008913/image-processing-queue-k79" \
  wiva002/java-sqs-client:latest "goat on a mountain"
```

## Oppgave 4: Metrics og Overvåkning:


### Beskrivelse av alarmen
CloudWatch Alarm for **SQS ApproximateAgeOfOldestMessage** er konfigurert i Terraform.
- **Terskelverdi**: Alarm trigges når alder på eldste melding overstiger `120 sekunder`.
- **E-postvarsling**: E-postvarsling er hardkodet med min e-postadresse `william.vage@gmail.com` for testing. Det ble gjort fordi oppgaven ikke spesifiserte at det skulle settes opp en secret for e-postadressen. I praksis burde man gjøre det.

### Viktig informasjon
E-postadressen for alarmvarsling er konfigurert som en variabel `var.alarm_email` i Terraform-koden. For å teste eller bruke alarmen med en annen e-postadresse, må følgende oppdateres:
- Endre verdien for variablen i `terraform_deploy.yml` i både `Terraform Plan` og `Terraform Apply` stegene.
```bash
- name: Terraform Plan
  run: terraform plan -var="alarm_email=your-email@example.com"
```
- Hvis du bruker Terraform lokalt, sørg for å oppdatere variabelen der også.

## Oppgave 5: Serverless vs Mikrotjenester

### Automatisering og kontinuerlig levering (CI/CD)

#### Serverless:
- CI/CD pipelines blir mer fragmentert fordi hver Lambda-funksjon kan ha sin egen livssyklus.
- Verktøy som AWS SAM og Serverless Framework forenkler deploy, men håndtering av mange små komponenter kan øke kompleksiteten.
- Raskere utrulling siden funksjoner kan oppdateres uavhengig.

#### Mikrotjenester:
- CI/CD pipelines er ofte enklere å håndtere da de er fokusert på større tjenester.
- Deployment kan være tregere siden flere avhengigheter oppdateres samtidig.
- Orkestreringsverktøy som Kubernetes hjelper med å administrere utrullingsstrategier, men krever mer oppsett.


### Observability (overvåkning)

#### Serverless:
- Logging og overvåking distribueres på tvers av mange små funksjoner, noe som krever verktøy som AWS CloudWatch.
- Feilsøking kan være utfordrende da hendelser spres over flere funksjoner og tjenester.
- Manglende direkte tilgang til infrastruktur gjør dyp feilsøking vanskelig.

#### Mikrotjenester:
- Tjenestebasert arkitektur gjør logging og feilsøking enklere å spore.
- Krever mer oppsett for metrics og overvåkning, men gir mer detaljert kontroll.


### Skalarbarhet og kostnadskontroll

#### Serverless:
- Skalerer automatisk basert på behov, og kostnadene er "pay as you go".
- God ressursutnyttelse ved uforutsigbar belastning, men kan bli dyrt ved konstant høy trafikk.
- Begrensninger som maksimal kjøretid på bare minutter kan være en ulempe.

#### Mikrotjenester:
- Gir full kontroll over ressursbruk og skaleringsstrategier.
- Overprovisjonering kan føre til høyere faste kostnader.
- passer bedre for stabile arbeidsmengder med jevn trafikk.


### Eierskap og ansvar

#### Serverless:
- Reduserer teamets ansvar for drift og infrastruktur, det håndteres av AWS.
- Gir mindre kontroll, men høy fleksibilitet og rask utvikling.
- Krever spesialkompetanse for å feilsøke serverless-arkitekturer.


#### Mikrotjenester:
- Teamet har full kontroll over infrastrukturen, som øker ansvar for ytelse og pålitelighet.
- Mer koordingering mellomg team nødvendig for å sikre integrasjon.
- Tilbyr mer fleksibilitet for skreddersydde løsninger.

## Konklusjon
- **Serverless** er best for systemer med uforutsigbar belastning og fokus på rask utvikling, mens **mikrotjenester** passer for komplekse systemer som krever høy kontroll og skalerbarhet.
- Valget avhenger av organisasjonens behov for skalerbarhet, fleksibilitet og ressurskontroll.


## Tabell

| Oppgave  | Leveranse                                                                                     |
|----------|-----------------------------------------------------------------------------------------------|
| Oppgave 1 | **HTTP Endepunkt:** [Lambda funksjon endepunkt](https://ra9v34knf1.execute-api.eu-west-1.amazonaws.com/Prod/generate-image/) <br> **GitHub Actions workflow:** [Workflow for SAM Deploy](https://github.com/williamvage123/PGR301-Exam-2024/actions/runs/12022752183/job/33515482927) |
| Oppgave 2 | **SQS URL:** [SQS Queue](https://sqs.eu-west-1.amazonaws.com/244530008913/image-processing-queue-k79) <br> **Terraform Main Workflow:** [Workflow for Main Branch](https://github.com/williamvage123/PGR301-Exam-2024/actions/runs/12022926943) <br> **Terraform Test Workflow:** [Workflow for Test Branch](https://github.com/williamvage123/PGR301-Exam-2024/actions/runs/12022965283/job/33516055961) |
| Oppgave 3 | **Dockerhub Image Name:** `wiva002/java-sqs-client:latest` <br> **GitHub Actions Workflow:** [Docker Publish Workflow](https://github.com/williamvage123/PGR301-Exam-2024/actions/runs/12023106074/job/33516457977) |
| Oppgave 4 | **CloudWatch Alarm:** Konfigurerbar via `var.alarm_email` i Terraform-koden. Dokumentert i README.md. |