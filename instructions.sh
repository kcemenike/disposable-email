KEY=$(cut -d = -f 2 .env)
# GET TOKEN
curl --request POST \
--url https://dropmail.p.rapidapi.com/ \
--header 'X-RapidAPI-Host: dropmail.p.rapidapi.com' \
--header "X-RapidAPI-Key: $KEY" \
--header 'content-type: application/json' \
--data "{\"query\":\"mutation { introduceSession { id, expiresAt, addresses { address }}}\"}" >creds.json

EMAIL=$(cut -d : -f 10 creds.json | sed "s/}//g;s/]//;s/\"//g")
TOKEN=$(cut -d : -f 4 creds.json | cut -d , -f 1 | sed "s/\"//g")
echo email=$EMAIL

# Wait
sleep 180s

# GET MESSAGE LIST
curl -s --request POST \
--url https://dropmail.p.rapidapi.com/ \
--header 'X-RapidAPI-Host: dropmail.p.rapidapi.com' \
--header "X-RapidAPI-Key: $KEY" \
--header 'content-type: application/json' \
--data "{\"query\":\"query checkSession(\$id : ID) {session(id: \\\"$TOKEN\\\") {mails{rawSize,fromAddr,toAddr,downloadUrl,text,headerSubject}}}\"}" >mailbox.json

# GET MESSAGE
FROM=$(cut -d , -f 5 mailbox.json | cut -d : -f 2 | sed "s/\"//g")
TO=$(cut -d , -f 1 mailbox.json | cut -d : -f 5 | sed "s/\"//g")
SUBJECT=$(cut -d , -f 4 mailbox.json | cut -d : -f 2 | sed "s/\"//g")
TEXT=$(cut -d , -f 2 mailbox.json | cut -d : -f 2 | sed "s/\"//g")
FILE=$(cut -d , -f 6 mailbox.json | cut -d : -f 2,3,4,5 | sed "s/\"//g;s/}//g;s/]//g")
curl -s $FILE >file.eml

# python -c """
# import sys, json;
# with open('mailbox.json') as w:
#   latest = json.load(w)['data']['session']['mails'][-1]
#   from_ = latest['fromAddr']
#   to = latest['toAddr']
#   subject = latest['headerSubject']
#   text = latest['text']
#   url = latest['downloadUrl']
#   print(from_, to, subject, text, url);
# with open('output.txt', 'w') as writer:
#   writer.write(f'from={from_}\n')
# with open('output.txt', 'a') as writer:
#   writer.write(f'to={to}\n')
#   writer.write(f'subject={subject}\n')
#   writer.write(f'url={url}\n')
#   writer.write(f'text={text}')
# """
