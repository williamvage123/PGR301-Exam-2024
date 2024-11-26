# PGR301 Exam

## Oppgave 1 - A:
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

## Oppgave 1 - B:
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