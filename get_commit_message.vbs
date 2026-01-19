' File: get_commit_message.vbs
' Questo script VBScript apre una finestra di dialogo per chiedere il messaggio di commit.

Dim Message, Result

Message = InputBox("Inserisci il messaggio per il Commit:","Messaggio di Commit Git","Aggiunta nuova lezione e appunti")

' Controlla se l'utente ha premuto Annulla (Result è vuoto)
If Message = "" Then
    ' Usa un codice di errore specifico (es. 'ANNULLATO') se l'utente annulla o non scrive nulla
    WScript.Echo "ANNULLATO"
Else
    WScript.Echo Message
End If