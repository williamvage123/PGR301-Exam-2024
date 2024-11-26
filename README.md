# PGR301 Exam

## Oppgave 1 - A:
### HTTP Endepunkt for Lambda Funksjonen:
    (https://ra9v34knf1.execute-api.eu-west-1.amazonaws.com/Prod/generate-image/)

### Testing med curl:
Her kan du teste enten med 'curl' eller i Postman:
Husk å skrive noe inne i "prompt" feltet! F.eks: "A man on top of an airplane."

```bash
curl -X POST https://ra9v34knf1.execute-api.eu-west-1.amazonaws.com/Prod/generate-image/ \
-H "Content-Type: application/json" \
-d '{ "prompt": "" }'
