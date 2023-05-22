Attribute VB_Name = "WinApiError"
Option Explicit
'Todo #If VBA7 Then ... and implement the API calls correctly for VBA7 LongPtr etc
'Last Change 20230419: Trim answer of WinErrorAsString

'Public Enum FileRWcommonErrors
    'Used Win Error Constants:
Private Const WIN_ERR_FILE_NOT_FOUND = 2             'Error 2 'Le fichier spécifié est introuvable.
Private Const WIN_ERR_PATH_NOT_FOUND = 3             'Error 3 'Le chemin d’accès spécifié est introuvable.
Private Const WIN_ERR_OPEN_DRIVEORFOLDER_AS_FILE = 4 'Error 4 'Le système ne peut pas ouvrir le fichier.
Private Const WIN_ERR_ACCESS_DENIED = 5              'Error 5 'Accès refusé.
Private Const WIN_ERR_INVALID_DESCRIPTION = 6        'Error 6 'Descripteur non valide
Private Const WIN_ERR_OUT_OF_MEMORY = 7              'Error 7 'Les blocs de contrôle de mémoire ont été détruits.
Private Const WIN_ERR_OUT_OF_STRING_SPACE = 14       'Error 14 'Mémoire insuffisante pour cette opération.
Private Const WIN_ERR_END_OF_FILE = 38               'Error 38 'Fin de fichier atteinte.
    'Special my Error Constants:
Private Const ERR_READ_WRITE_ON_CLOSED_FILE = 1000000                          '"Trying to read or write on closed file."
Private Const ERR_FILEEXISTS_FORWRITING_NOTOVERWRITE_NOTFORAPPEND = 1000001    '"File exists and ForWriting and Not Overwrite and Not ForAppending."
Private Const ERR_SETTING_END_OF_FILE = 1000002                                '"SetEndOfFile failed (for overwriting)."
Private Const ERR_WRONG_TEXT_FORMAT = 1000003                                  '"Wrong text format."
Private Const ERR_WRONG_TEXT_FORMAT_UNICODE_CONTENT_IN_ANSI_FILE = 1000004     'Wrong text format, trying to write Unicode Content in Ansi file."
Private Const ERR_WRONG_TEXT_FORMAT_UNICODE_CONTENT_IN_BINARY_FILE = 1000005   'Wrong text format, trying to write Unicode Content in Ansi file."
Private Const ERR_CORRUPTED_FILE = 1000005                                     '"Corrupted file."
'End Enum

Private Const MAX_PATH As Long = 520& 'Unicode '260& 'For Ansi, but more doubble space needed for Unicode Calls (function declare W). Also working with Unicode, tested on Win98 1.7.2019.

'API call and Constants for transfomring win API error to string:
'declare AW ansi unicode ok
'Ansi
Private Declare Function FormatMessageA Lib "kernel32" _
  (ByVal dwFlags As Long, _
   lpSource As Long, _
   ByVal dwMessageId As Long, _
   ByVal dwLanguageId As Long, _
   ByVal lpBuffer As String, _
   ByVal nSize As Long, _
   Args As Any) As Long ' equalsBinaryTestAok no need cause received memory
'Unicode
Private Declare Function FormatMessageW Lib "kernel32" _
  (ByVal dwFlags As Long, _
   lpSource As Long, _
   ByVal dwMessageId As Long, _
   ByVal dwLanguageId As Long, _
   ByVal lpBuffer As String, _
   ByVal nSize As Long, _
   Args As Any) As Long
'declare AW ansi unicode ok
Private Const LB_SETTABSTOPS As Long = &H192&
Private Const FORMAT_MESSAGE_FROM_SYSTEM As Long = &H1000&
Private Const FORMAT_MESSAGE_IGNORE_INSERTS As Long = &H200&
Private Const FORMAT_MESSAGE_MAX_Width_MASK As Long = &HFF&
Private Const FORMAT_MESSAGE_ARGUMENT_ARRAY As Long = &H2000&

'API error to string:
Public Function WinErrorAsString(ByVal MsgID As Long) As String
   
   'Normal windows errors
   Dim Ret As Long
   Dim sVal As String
   Dim sBuff As String
   sBuff = Space$(MAX_PATH)
   Ret = FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM Or _
                        FORMAT_MESSAGE_IGNORE_INSERTS Or _
                        FORMAT_MESSAGE_MAX_Width_MASK, _
                        0&, MsgID, 0&, _
                        sBuff, Len(sBuff), 0&) 'Unicode Call
   If Ret = 0 Then
        'problem Unicode, call Ansi
        sBuff = Space$(MAX_PATH)
        Ret = FormatMessageA(FORMAT_MESSAGE_FROM_SYSTEM Or _
                             FORMAT_MESSAGE_IGNORE_INSERTS Or _
                             FORMAT_MESSAGE_MAX_Width_MASK, _
                             0&, MsgID, 0&, _
                             sBuff, Len(sBuff), 0&) 'Ansi Call  ' equalsBinaryTestAok no need cause received memory
        If Ret = 0 Then
             'problem Ansi, call nothing
             sBuff = ""
        Else
             sBuff = Left$(sBuff, Ret) 'Ansi Result
        End If
   Else
        sBuff = Left$(StrConv(sBuff, vbFromUnicode), Ret) 'Unicode Result
   End If
   
   If Ret Then
      WinErrorAsString = sBuff
   Else
      WinErrorAsString = ""
   End If
   
   'finally Test if Used FileRWcommonErrors defined in FileRW Class
    'Public Enum FileRWcommonErrors
    '    'Used Win Error Constants:
    '    WIN_ERR_FILE_NOT_FOUND = 2             'Error 2 'Le fichier spécifié est introuvable.
    '    WIN_ERR_PATH_NOT_FOUND = 3             'Error 3 'Le chemin d’accès spécifié est introuvable.
    '    WIN_ERR_OPEN_DRIVEORFOLDER_AS_FILE = 4 'Error 4 'Le système ne peut pas ouvrir le fichier.
    '    WIN_ERR_ACCESS_DENIED = 5              'Error 5 'Accès refusé.
    '    WIN_ERR_INVALID_DESCRIPTION = 6        'Error 6 'Descripteur non valide
    '    WIN_ERR_OUT_OF_MEMORY = 7              'Error 7 'Les blocs de contrôle de mémoire ont été détruits.
    '    WIN_ERR_OUT_OF_STRING_SPACE = 14       'Error 14 'Mémoire insuffisante pour cette opération.
    '    WIN_ERR_END_OF_FILE = 38               'Error 38 'Fin de fichier atteinte.
    '    'Special my Error Constants:
    '    ERR_READ_WRITE_ON_CLOSED_FILE = 1000000                                   '"Trying to read or write on closed file"
    '    ERR_FILEEXISTS_FORWRITING_NOTOVERWRITE_NOTFORAPPEND = 1000001 '"File exists and ForWriting and Not Overwrite and Not ForAppending"
    '    ERR_SETTING_END_OF_FILE = 1000002                                         '"SetEndOfFile failed (for Overwriting)"
    '    ERR_WRONG_TEXT_FORMAT = 1000003                                           '"Wrong text format"
    '    ERR_WRONG_TEXT_FORMAT_UNICODE_CONTENT_IN_ANSI_FILE = 1000004              '"Wrong text format, trying to write Unicode content in Ansi file"
    '    ERR_WRONG_TEXT_FORMAT_UNICODE_CONTENT_IN_BINARY_FILE = 1000005   'Wrong text format, trying to write Unicode content in Ansi file."
    '    ERR_CORRUPTED_FILE = 1000005                                              '"Corrupted file"
    'End Enum
   Select Case MsgID
      'Used Win Error Constants: Add suffix to WinErrorAsString
      Case WIN_ERR_FILE_NOT_FOUND
         WinErrorAsString = WinErrorAsString
      Case WIN_ERR_PATH_NOT_FOUND
         WinErrorAsString = WinErrorAsString
      Case WIN_ERR_OPEN_DRIVEORFOLDER_AS_FILE
         WinErrorAsString = WinErrorAsString & "(Maybe  Path is folder, drive or other device)."
      Case WIN_ERR_ACCESS_DENIED
         WinErrorAsString = WinErrorAsString
      Case WIN_ERR_INVALID_DESCRIPTION
         WinErrorAsString = WinErrorAsString & "(Maybe writing a file that is open in read mode only)."
      Case WIN_ERR_OUT_OF_MEMORY
         WinErrorAsString = WinErrorAsString & "(Out of memory)."
      Case WIN_ERR_OUT_OF_STRING_SPACE
         WinErrorAsString = WinErrorAsString & "(Out of String space)."
      Case WIN_ERR_END_OF_FILE
         WinErrorAsString = WinErrorAsString & "(End of file)."
         
      'Special my Error Constants: WinErrorAsString should return "", just Add my text
      Case ERR_READ_WRITE_ON_CLOSED_FILE
         WinErrorAsString = WinErrorAsString & "Trying to read or write on closed file."
      Case ERR_FILEEXISTS_FORWRITING_NOTOVERWRITE_NOTFORAPPEND
         WinErrorAsString = WinErrorAsString & "File exists and ForWriting and Not Overwrite and Not ForAppending."
      Case ERR_SETTING_END_OF_FILE
         WinErrorAsString = WinErrorAsString & "SetEndOfFile failed (for Overwriting)."
      Case ERR_WRONG_TEXT_FORMAT
         WinErrorAsString = WinErrorAsString & "Wrong text format."
      Case ERR_WRONG_TEXT_FORMAT_UNICODE_CONTENT_IN_ANSI_FILE
         WinErrorAsString = WinErrorAsString & "Wrong text format, trying to write Unicode content in Ansi file."
      Case ERR_WRONG_TEXT_FORMAT_UNICODE_CONTENT_IN_BINARY_FILE
         WinErrorAsString = WinErrorAsString & "Wrong text format, trying to write Unicode content in Binary file."
      Case ERR_CORRUPTED_FILE
         WinErrorAsString = WinErrorAsString & "Corrupted file."
   End Select
   If Len(WinErrorAsString) > 0 Then
      If Left(WinErrorAsString, 1) <> " " Then
         WinErrorAsString = WinErrorAsString & " "
      End If
   End If
   WinErrorAsString = "Error " & CStr(MsgID) & ": " & Trim(WinErrorAsString)
End Function

'RESULTS FOR WinApiError.WinErrorAsString(ErrorNumber) (Windows 10)
'
'Error 0 'L’opération a réussi.
'Error 1 'Fonction incorrecte.
'Error 2 'Le fichier spécifié est introuvable.
'Error 3 'Le chemin d’accès spécifié est introuvable.
'Error 4 'Le système ne peut pas ouvrir le fichier.
'Error 5 'Accès refusé.
'Error 6 'Descripteur non valide
'Error 7 'Les blocs de contrôle de mémoire ont été détruits.
'Error 8 'Espace insuffisant pour traiter cette commande.
'Error 9 'Adresse de bloc de contrôle de stockage non valide.
'Error 10 'Environnement incorrect.
'Error 11 'Tentative de chargement d’un programme de format incorrect.
'Error 12 'Code d’accès non valide.
'Error 13 'Données non valides.
'Error 14 'Mémoire insuffisante pour cette opération.
'Error 15 'Le lecteur spécifié est introuvable.
'Error 16 'Impossible de supprimer le répertoire.
'Error 17 'Impossible de déplacer le fichier vers un lecteur de disque différent.
'Error 18 'Il n’y a plus de fichier.
'Error 19 'Média protégé en écriture.
'Error 20 'Le périphérique spécifié est introuvable.
'Error 21 'Le périphérique n’est pas prêt.
'Error 22 'Le périphérique ne reconnaît pas la commande.
'Error 23 'Erreur de données (contrôle de redondance cyclique).
'Error 24 'Le programme a émis une commande de longueur incorrecte.
'Error 25 'Le lecteur ne trouve pas de zone ou de piste spécifique sur le disque.
'Error 26 'Impossible d’accéder au disque ou à la disquette spécifié.
'Error 27 'Le lecteur ne trouve pas le secteur demandé.
'Error 28 'L’imprimante n’a plus de papier.
'Error 29 'Écriture impossible sur le périphérique spécifié.
'Error 30 'Lecture impossible sur le périphérique spécifié.
'Error 31 'Un périphérique attaché au système ne fonctionne pas correctement.
'Error 32 'Le processus ne peut pas accéder au fichier car ce fichier est utilisé par un autre processus.
'Error 33 'Le processus ne peut pas accéder au fichier car un autre processus en a verrouillé une partie.
'Error 34 'Le lecteur ne contient pas la bonne disquette. Insérez %2 (numéro de série de volume : %3) dans le lecteur %1.
'Error 36 'Trop de fichiers ouverts pour un partage.
'Error 38 'Fin de fichier atteinte.
'Error 39 'Le disque est plein.
'Error 50 'Cette demande n’est pas prise en charge.
'Error 51 'Windows ne trouve pas le chemin d’accès réseau. Vérifiez que le chemin est valide, et que l’ordinateur de destination n’est pas occupé ou désactivé. Si l’erreur se reproduit, contactez votre administrateur réseau.
'Error 52 'Vous n’étiez pas connecté car il y avait un nom en double sur le réseau. Si vous joignez un domaine, ouvrez le Panneau de configuration Système et modifiez le nom de l’ordinateur, puis réessayez. Si vous joignez un groupe de travail, choisissez un autre nom po
'Error 53 'Le chemin réseau n’a pas été trouvé.
'Error 54 'Le réseau est occupé.
'Error 55 'La ressource ou le périphérique réseau spécifié n’est plus disponible.
'Error 56 'La limite de commandes NetBIOS a été atteinte.
'Error 57 'Une erreur de carte réseau s’est produite.
'Error 58 'Le serveur spécifié ne peut pas exécuter l’opération demandée.
'Error 59 'Erreur réseau inattendue.
'Error 60 'La carte distante n’est pas compatible.
'Error 61 'La file d’attente de l’imprimante est saturée.
'Error 62 'Le serveur ne dispose pas de suffisamment d’espace pour stocker le fichier à imprimer.
'Error 63 'Votre fichier en attente d’impression a été supprimé.
'Error 64 'Le nom réseau spécifié n’est plus disponible.
'Error 65 'Accès au réseau refusé.
'Error 66 'Le type de ressource réseau est incorrect.
'Error 67 'Nom de réseau introuvable.
'Error 68 'La limite de nom pour la carte réseau de l’ordinateur local a été dépassée.
'Error 69 'Dépassement de la limite de sessions NetBIOS.
'Error 70 'Le serveur distant a été suspendu ou se trouve en phase de démarrage.
'Error 71 'Il n’est plus possible d’établir une connexion avec cet ordinateur distant en ce moment car il y a déjà autant de connexions que l’ordinateur peut en accepter.
'Error 72 'L’imprimante ou le périphérique disque spécifié a été suspendu.
'Error 80 'Le fichier existe.
'Error 82 'Impossible de créer le répertoire ou le fichier.
'Error 83 'Échec sur l’interruption 24.
'Error 84 'Mémoire insuffisante pour traiter cette demande.
'Error 85 'Nom de périphérique local déjà utilisé.
'Error 86 'Le mot de passe réseau spécifié est incorrect.
'Error 87 'Paramètre incorrect.
'Error 88 'Erreur lors de l’écriture sur le réseau.
'Error 89 'Le système ne peut pas exécuter un autre processus en ce moment.
'Error 100 'Impossible de créer un autre sémaphore système.
'Error 101 'Un autre processus possède le sémaphore exclusif.
'Error 102 'Le sémaphore est établi et ne peut pas être fermé.
'Error 103 'Le sémaphore ne peut pas être rétabli.
'Error 104 'Impossible de demander des sémaphores exclusifs lors d’une interruption.
'Error 105 'Ce sémaphore n’a plus de propriétaire.
'Error 106 'Insérez la disquette destinée au lecteur %1.
'Error 107 'Le programme s’est arrêté car vous n’avez pas inséré d’autre disquette.
'Error 108 'Le disque est soit en cours d’utilisation, soit verrouillé par un autre processus.
'Error 109 'Le canal de communication a été fermé.
'Error 110 'Impossible d’ouvrir le périphérique ou le fichier spécifié.
'Error 111 'Le nom du fichier est trop long.
'Error 112 'Espace insuffisant sur le disque.
'Error 113 'Il n’y a plus d’identificateur de fichier interne disponible.
'Error 114 'L’identificateur interne de fichier cible est incorrect.
'Error 117 'L’appel IOCTL émis par l’application n’est pas correct.
'Error 118 'La valeur du paramètre de vérification durant l’écriture est incorrecte.
'Error 119 'Le système ne prend pas en charge la commande demandée.
'Error 120 'Cette fonction n’est pas prise en charge par le système.
'Error 121 'Le délai de temporisation de sémaphore a expiré.
'Error 122 'La zone de données passée à un appel système est insuffisante.
'Error 123 'La syntaxe du nom de fichier, de répertoire ou de volume est incorrecte.
'Error 124 'Niveau d’appel système incorrect.
'Error 125 'Le disque n’a pas de nom de volume.
'Error 126 'Le module spécifié est introuvable.
'Error 127 'La procédure spécifiée est introuvable.
'Error 128 'Il n’y a pas de processus enfant à attendre.
'Error 129 'L’application %1 ne peut être exécutée en mode Win32.
'Error 130 'Tentative d’utilisation d’un descripteur de fichier sur une partition de disque ouverte pour une opération différente d’une E/S disque brute.
'Error 131 'Tentative de déplacement du pointeur de fichier avant le début du fichier.
'Error 132 'Impossible d’établir le pointeur de fichier sur le périphérique ou le fichier spécifié.
'Error 133 'Les commandes JOIN ou SUBST ne peuvent pas être utilisées pour un lecteur qui contient déjà des lecteurs joints.
'Error 134 'Tentative d’utilisation d’une commande JOIN ou SUBST sur un lecteur qui a déjà été joint.
'Error 135 'Tentative d’utilisation d’une commande JOIN ou SUBST sur un lecteur qui a déjà été substitué.
'Error 136 'Le système a tenté de supprimer la jointure d’un lecteur non joint.
'Error 137 'Le système a tenté de supprimer la substitution d’un lecteur non substitué.
'Error 138 'Le système a tenté de joindre un lecteur à un répertoire stocké sur un lecteur joint.
'Error 139 'Le système a tenté de substituer un lecteur à un répertoire stocké sur un lecteur substitué.
'Error 140 'Le système a tenté de joindre un lecteur à un répertoire stocké sur un lecteur substitué.
'Error 141 'Le système a tenté de substituer un lecteur à un répertoire stocké sur un lecteur joint.
'Error 142 'Opération JOIN ou SUBST impossible maintenant.
'Error 143 'Le système ne peut pas joindre ou substituer un lecteur à un répertoire sur ce même lecteur.
'Error 144 'Le répertoire n’est pas un sous-répertoire du répertoire racine.
'Error 145 'Le répertoire n’est pas vide.
'Error 146 'Le chemin spécifié est utilisé dans une substitution.
'Error 147 'Ressources insuffisantes pour traiter cette commande.
'Error 148 'Impossible d’utiliser maintenant le chemin spécifié.
'Error 149 'Tentative de jointure ou de substitution d’un lecteur dont un répertoire est la cible d’une substitution antérieure.
'Error 150 'Soit les informations de trace du système n’ont pas été spécifiées dans votre fichier CONFIG.SYS, soit la trace est interdite.
'Error 151 'Le nombre d’événements sémaphore spécifié pour DosMuxSemWait n’est pas correct.
'Error 152 'DosMuxSemWait ne s’est pas exécuté. Trop de sémaphores ont déjà été établis.
'Error 153 'Liste DosMuxSemWait incorrecte.
'Error 154 'Le nom de volume entré dépasse le nombre limite de caractères du système de fichiers de destination.
'Error 155 'Impossible de créer un autre thread.
'Error 156 'Le processus destinataire a refusé le signal.
'Error 157 'Le segment est déjà abandonné et ne peut être verrouillé.
'Error 158 'Segment déjà déverrouillé.
'Error 159 'L’adresse de l’ID de thread est incorrecte.
'Error 160 'Un ou plusieurs arguments sont incorrects.
'Error 161 'Le chemin d’accès spécifié n’est pas valide.
'Error 162 'Un signal est déjà en attente.
'Error 164 'Le système ne peut pas créer davantage de threads.
'Error 167 'Impossible de verrouiller une partie d’un fichier.
'Error 170 'La ressource demandée est en cours d’utilisation.
'Error 171 'La détection de la prise en charge des commandes du périphérique est en cours.
'Error 173 'Aucune requête de verrouillage n’était en attente pour la région d’annulation.
'Error 174 'Le système de fichiers n’autorise pas les modifications atomiques du type de verrou.
'Error 180 'Le système a détecté un numéro de segment incorrect.
'Error 182 'Le système d’exploitation ne peut pas exécuter %1.
'Error 183 'Impossible de créer un fichier déjà existant.
'Error 186 'L’indicateur passé est incorrect.
'Error 187 'Le nom de sémaphore système spécifié n’a pas été trouvé.
'Error 188 'Le système d’exploitation ne peut pas exécuter %1.
'Error 189 'Le système d’exploitation ne peut pas exécuter %1.
'Error 190 'Le système d’exploitation ne peut pas exécuter %1.
'Error 191 'Impossible d’exécuter %1 en mode Win32.
'Error 192 'Le système d’exploitation ne peut pas exécuter %1.
'Error 193 '%1 n’est pas une application Win32 valide.
'Error 194 'Le système d’exploitation ne peut pas exécuter %1.
'Error 195 'Le système d’exploitation ne peut pas exécuter %1.
'Error 196 'Le système d’exploitation ne peut pas exécuter ce programme d’application.
'Error 197 'Actuellement, le système d’exploitation n’est pas configuré pour exécuter cette application.
'Error 198 'Le système d’exploitation ne peut pas exécuter %1.
'Error 199 'Le système d’exploitation ne peut pas exécuter ce programme d’application.
'Error 200 'Le segment code ne peut pas être supérieur ou égal à 64 Ko.
'Error 201 'Le système d’exploitation ne peut pas exécuter %1.
'Error 202 'Le système d’exploitation ne peut pas exécuter %1.
'Error 203 'Le système n’a pas trouvé l’option d’environnement spécifiée.
'Error 205 'Aucun processus dans la sous-arborescence de la commande n’a un manipulateur de signal.
'Error 206 'Nom de fichier ou extension trop long.
'Error 207 'La pile de l’anneau 2 est actuellement utilisée.
'Error 208 'Les caractères génériques (* ou ?) ont été spécifiés de manière incorrecte ou en trop grand nombre.
'Error 209 'Le signal à inscrire est incorrect.
'Error 210 'Le manipulateur de signal ne peut être établi.
'Error 212 'Le segment est verrouillé et ne peut être réaffecté.
'Error 214 'Trop de modules de liaison dynamique sont attachés à ce programme ou à ce module de liaison dynamique.
'Error 215 'Impossible d’imbriquer les appels de LoadModule.
'Error 216 'Cette version de %1 n’est pas compatible avec la version de Windows actuellement exécutée. Vérifiez dans les informations système de votre ordinateur, puis contactez l’éditeur de logiciel.
'Error 217 'Le fichier image %1 est signé, impossible à modifier.
'Error 218 'Le fichier image %1 est signé, impossible à modifier.
'Error 220 'Ce fichier est extrait ou verrouillé pour modification par un autre utilisateur.
'Error 221 'Le fichier doit être extrait avant l’enregistrement des modifications.
'Error 222 'Le type de fichier en cours d’enregistrement ou d’extraction a été bloqué.
'Error 223 'Impossible d’enregistrer le fichier car sa taille dépasse la limite autorisée.
'Error 224 'Accès refusé. Avant d’ouvrir des fichiers de cet emplacement, vous devez d’abord ajouter le site Web à votre liste de sites approuvés, accéder au site Web, puis sélectionner l’option de connexion automatique.
'Error 225 'Impossible de terminer l’opération, car le fichier contient un virus ou un logiciel potentiellement indésirable.
'Error 226 'Ce fichier contient un virus ou un logiciel potentiellement indésirable et ne peut pas être ouvert. Compte tenu de la nature du virus ou du logiciel potentiellement indésirable, le fichier a été supprimé de cet emplacement.
'Error 229 'Le canal est local.
'Error 230 'L’état du canal de communication n’est pas valide.
'Error 231 'Toutes les instances des canaux de communication sont occupées.
'Error 232 'Le canal de communication est sur le point d’être fermé.
'Error 233 'Il n’y a pas de processus à l’autre extrémité du canal.
'Error 234 'Plus de données sont disponibles .
'Error 235 'L’action demandée a entraîné l’absence de travail effectué. Le nettoyage de style d’erreur a été effectué.
'Error 240 'La session a été annulée.
'Error 254 'Le nom d’attribut étendu (EA) spécifié n’était pas valide.
'Error 255 'Les attributs étendus (EA) sont incohérents.
'Error 258 'Dépassement du délai d’attente.
'Error 259 'Aucune donnée n’est disponible.
'Error 266 'Les fonctions de copie ne peuvent pas être utilisées.
'Error 267 'Nom de répertoire non valide.
'Error 275 'Les attributs étendus (EA) ne tiennent pas dans le tampon.
'Error 276 'Le fichier d’attributs étendus sur le système de fichiers monté est endommagé.
'Error 277 'Le fichier de la table des attributs étendus (EA) est plein.
'Error 278 'Le descripteur d’attributs étendus (EA) spécifié n’est pas valide.
'Error 282 'Le système de fichiers monté n’autorise pas les attributs étendus.
'Error 288 'Tentative de libération d’un mutex dont l’appelant n’est pas propriétaire.
'Error 298 'Un sémaphore a subi trop d’inscriptions.
'Error 299 'Seule une partie d’une requête ReadProcessMemory ou WriteProcessMemory a été effectuée.
'Error 300 'La requête oplock est refusée.
'Error 301 'Un accusé de réception oplock non valide a été reçu par le système.
'Error 302 'Le volume est trop fragmenté pour terminer cette opération.
'Error 303 'Le fichier ne peut pas être ouvert car il est en cours de suppression.
'Error 304 'Les paramètres de nom court ne peuvent pas être modifiés sur ce volume à cause d’un paramètre de Registre global.
'Error 305 'Les noms courts ne sont pas activés sur ce volume.
'Error 306 'Le flux de sécurité pour le volume donné présente un état incohérent. Exécutez CHKDSK sur le volume.
'Error 307 'Une opération de verrouillage de fichier demandée ne peut pas être traitée en raison d’une plage d’octets non valide.
'Error 308 'Le sous-système requis pour prendre en charge le type d’image n’est pas présent.
'Error 309 'Le fichier spécifié possède déjà un GUID de notification associé.
'Error 310 'Une routine de gestionnaire d’exceptions non valide a été détectée.
'Error 311 'Des privilèges dupliqués ont été spécifiés pour le jeton.
'Error 312 'Aucune plage n’a pu être traitée pour l’opération spécifiée.
'Error 313 'Cette opération n’est pas autorisée sur un fichier interne du système de fichiers.
'Error 314 'Les ressources physiques de ce disque ont été épuisées.
'Error 315 'Le jeton représentant les données n’est pas valide.
'Error 316 'Le périphérique ne prend pas en charge la fonctionnalité de la commande.
'Error 317 'Le texte du message associé au numéro 0x%1 est introuvable dans le fichier de messages pour %2.
'Error 318 'L’étendue spécifiée est introuvable.
'Error 319 'La stratégie d’accès centralisé spécifiée n’est pas définie sur l’ordinateur cible.
'Error 320 'La stratégie d’accès centralisé obtenue d’Active Directory n’est pas valide.
'Error 321 'Le périphérique n’est pas accessible.
'Error 322 'Le périphérique cible ne dispose pas de suffisamment de ressources pour terminer l’opération.
'Error 323 'Une erreur de somme de contrôle d’intégrité des données s’est produite. Les données contenues dans le flux de fichiers sont endommagées.
'Error 324 'Une tentative de modification d’un attribut étendu (AE) NOYAU et normal a eu lieu dans une même opération.
'Error 326 'Le périphérique ne prend pas en charge TRIM au niveau du fichier.
'Error 327 'La commande a spécifié un décalage de données qui ne respecte pas la granularité ou l’alignement du périphérique.
'Error 328 'La commande a spécifié un champ non valide dans sa liste de paramètres.
'Error 329 'Une opération est actuellement en cours avec le périphérique.
'Error 330 'Une tentative visant à envoyer la commande au périphérique cible par le biais d’un chemin d’accès non valide a été effectuée.
'Error 331 'La commande a spécifié un nombre de descripteurs supérieur au maximum pris en charge par le périphérique.
'Error 332 'La modification est désactivée sur le fichier spécifié.
'Error 333 'Le périphérique de stockage ne fournit pas de redondance.
'Error 334 'Une opération n’est pas prise en charge sur un fichier résident.
'Error 335 'Une opération n’est pas prise en charge sur un fichier compressé.
'Error 336 'Une opération n’est pas prise en charge sur un répertoire.
'Error 337 'Impossible de lire la copie spécifiée des données demandées.
'Error 338 'Impossible d’écrire les données spécifiées sur aucune des copies.
'Error 339 'Il se peut qu’une ou plusieurs copies des données présentes sur ce périphérique soient désynchronisées. Aucune écriture ne peut s’accomplir tant qu’une analyse de l’intégrité des données n’a pas été effectuée.
'Error 340 'La version des informations de noyau fournie n’est pas valide.
'Error 341 'La version des informations PEP fournie n’est pas valide.
'Error 342 'Cet objet ne dispose pas d’un fournisseur sous-jacent externe.
'Error 343 'Le fournisseur sous-jacent externe n’est pas reconnu.
'Error 344 'La compression de cet objet ne permettrait pas d'économiser de l'espace.
'Error 345 'Échec de la demande en raison d'une non-concordance des ID de topologie de stockage.
'Error 346 'L 'opération a été bloquée par les contrôles parentaux.
'Error 347 'Un bloc de système de fichiers en cours de référencement a déjà atteint le nombre maximum de références et ne peut pas être davantage référencé.
'Error 348 'Échec de l'opération demandée, car le flux de fichiers est marqué pour ne pas autoriser les écritures.
'Error 349 'L 'opération demandée a échoué avec un code d'échec spécifique à l'architecture.
'Error 350 'Aucune action n’a été prise car un redémarrage système est nécessaire.
'Error 351 'Échec de l’arrêt.
'Error 352 'Échec du redémarrage.
'Error 353 'Nombre maximal de sessions atteint.
'Error 354 'La stratégie de Protection des informations Windows ne permet pas d’accéder à cette ressource réseau.
'Error 355 'Le tampon du nom indicateur de l'appareil est trop petit pour recevoir le nom restant.
'Error 356 'L’opération demandée a été bloquée par la stratégie Protection des informations Windows. Pour plus d’informations, contactez votre administrateur système.
'Error 357 'L’opération demandée ne peut pas être effectuée, car la configuration matérielle ou logicielle de l’appareil ne respecte pas la Protection des informations Windows définie sous Stratégie de verrouillage. Vérifiez que le code PIN de l’utilisateur a été créé. Po
'Error 358 'Les métadonnées de la racine de synchronisation du cloud sont corrompues.
'Error 359 'Cet appareil est en mode maintenance.
'Error 360 'Cette opération n’est pas prise en charge sur un volume DAX.
'Error 361 'Le volume comporte des mappages DAX actifs.
'Error 362 'Le fournisseur de fichier cloud n’est pas en cours d'exécution.
'Error 363 'Les métadonnées du fichier cloud sont corrompues et illisibles.
'Error 364 'Les métadonnées du fichier cloud sont trop volumineuses.
'Error 365 'La propriété du fichier cloud est trop volumineuse.
'Error 366 'Il est possible que la propriété du fichier cloud soit corrompue. La somme de contrôle sur le disque ne correspond pas à la somme calculée.
'Error 367 'La création de processus a été bloquée.
'Error 368 'Le dispositif de stockage présente une perte de données ou de persistance.
'Error 369 'Le fournisseur prenant en charge la virtualisation du système de fichiers est temporairement indisponible.
'Error 370 'Les métadonnées pour la virtualisation du système de fichiers sont corrompues et illisibles.
'Error 371 'Le fournisseur prenant en charge la virtualisation du système de fichiers est trop occupé pour terminer cette opération.
'Error 372 'Le fournisseur prenant en charge la virtualisation du système de fichiers est inconnu.
'Error 373 'Les descripteurs GDI ont potentiellement fait l’objet d’une fuite par l’application.
'Error 374 'Le nombre maximal de propriétés du fichier cloud a été atteint.
'Error 375 'La version de la propriété du fichier cloud n'est pas prise en charge.
'Error 376 'Le fichier n’est pas un fichier cloud.
'Error 377 'Le fichier cloud n’est pas synchronisé avec le cloud.
'Error 378 'La racine de synchronisation du cloud s'est déjà connectée à un autre moteur de synchronisation du cloud.
'Error 379 'L 'opération n'est pas prise en charge par le moteur de synchronisation du cloud.
'Error 380 'L 'opération de cloud n'est pas valide.
'Error 381 'L 'opération de cloud n'est pas prise en charge sur un volume en lecture seule.
'Error 382 'L 'opération est réservée au moteur de synchronisation du cloud connecté.
'Error 383 'Le moteur de synchronisation du cloud n'a pas pu valider les données téléchargées.
'Error 384 'Vous ne pouvez pas vous connecter au partage de fichier, car il n'est pas sécurisé. Ce partage nécessite le protocole SMB1 obsolète qui n'est pas sûr et qui expose votre systèmes aux attaques. Votre système nécessite SMB2 ou un protocole plus avancé. Pour plus
'Error 385 'L 'opération de virtualisation n’est pas autorisée sur le fichier dans son état actuel.
'Error 386 'Le moteur de synchronisation du cloud n'est pas parvenu à effectuer l'authentification de l'utilisateur.
'Error 387 'Le moteur de synchronisation du cloud n'est pas parvenu à effectuer l'opération en raison de ressources système insuffisantes.
'Error 388 'Le moteur de synchronisation du cloud n'est pas parvenu à effectuer l'opération en raison de l'indisponibilité du réseau.
'Error 389 'L 'opération de cloud a échoué.
'Error 390 'L 'opération n'est prise en charge que sur des fichiers avec une racine de synchronisation dans le cloud.
'Error 391 'L’opération ne peut pas être effectuée sur des fichiers cloud en cours d'utilisation.
'Error 392 'L’opération ne peut pas être effectuée sur des fichiers cloud épinglés.
'Error 393 'L 'opération de cloud a été interrompue.
'Error 394 'Le magasin de propriétés du fichier dans le cloud est corrompu.
'Error 395 'L 'accès au fichier cloud est refusé.
'Error 396 'Impossible d 'exécuter l'opération de cloud sur un fichier comportant des liaisons permanentes.
'Error 397 'Échec de l'opération demandée en raison du verrouillage des propriétés d'un fichier cloud en conflit.
'Error 398 'L 'opération de cloud a été annulée par l'utilisateur.
'Error 399 'Un syskey chiffré en externe a été configuré, mais le système ne prend plus en charge cette fonctionnalité. Voir https://go.microsoft.com/fwlink/?linkid=851152 pour plus d'informations.
'Error 400 'Le thread est déjà en mode de traitement en arrière-plan.
'Error 401 'Le thread n’est pas en mode de traitement en arrière-plan.
'Error 402 'Le processus est déjà en mode de traitement en arrière-plan.
'Error 403 'Le processus n’est pas en mode de traitement en arrière-plan.
'Error 450 'Aucun mode déverrouillé pour développeur ni mode de chargement de version Test n'est activé sur le périphérique.
'Error 451 'Impossible de modifier le type d'application pendant une mise à niveau ou une remise en service.
'Error 452 'L 'application n'a pas été mise en service.
'Error 453 'La fonctionnalité demandée ne peut pas être autorisée pour cette application.
'Error 454 'Il n 'existe aucune stratégie d'autorisation de fonctionnalité sur le périphérique.
'Error 455 'La base de données d'autorisation de fonctionnalité a été endommagée.
'Error 456 'Le SCCD de la fonctionnalité personnalisée possède un catalogue non valide.
'Error 457 'Aucune correspondance n'est autorisée dans le SCCD.
'Error 458 'Échec de l’analyse du SCCD de la fonctionnalité personnalisée.
'Error 459 'Le SCCD de la fonctionnalité personnalisée nécessite le mode développeur.
'Error 460 'Toutes les fonctionnalités personnalisées déclarées ne sont pas détectées dans le SCCD.
'Error 480 'Le délai de l’opération a expiré. En raison d’un arrêt éventuel dans sa pile de périphériques, cet appareil n’a pas pu terminer une demande de suppression de requête PnP. Vous devez redémarrer le système pour terminer cette demande.
'Error 481 'Le délai de l’opération a expiré. En raison d’un arrêt éventuel dans la pile de périphériques d’un appareil associé, cet appareil n’a pas pu terminer une demande de suppression de requête PnP. Vous devez redémarrer le système pour terminer l’opération.
'Error 482 'Le délai de l’opération a expiré. En raison d’un arrêt éventuel dans la pile de périphériques d’un appareil non associé, cet appareil n’a pas pu terminer une demande de suppression de requête PnP. Vous devez redémarrer le système pour terminer l’opération.
'Error 483 'Échec de la requête en raison d’une grave erreur matérielle de l’appareil.
'Error 487 'Tentative d’accès à une adresse non valide.
'Error 500 'Impossible de charger le profil d’utilisateur.
'Error 534 'Résultat arithmétique dépassant 32 bits.
'Error 535 'Il y a un processus à l’autre extrémité du canal.
'Error 536 'Le système attend qu’un processus ouvre l’autre extrémité du canal.
'Error 537 'L’outil Application Verifier a rencontré une erreur dans le processus actuel.
'Error 538 'Une erreur s’est produite dans le sous-système ABIOS.
'Error 539 'Un avertissement s’est produit dans le sous-système WX86.
'Error 540 'Une erreur s’est produite dans le sous-système WX86.
'Error 541 'Tentative d’annulation ou d’établissement d’un minuteur associé à un sous-programme APC alors que le thread sujet n’est pas celui qui a initialement établi le minuteur et l’APC associé.
'Error 542 'Code d’exception de déroulage.
'Error 543 'Une pile non valide ou non alignée a été rencontrée lors d’une opération de déroulage.
'Error 544 'Une cible de déroulement non valide a été rencontrée lors d’une opération de déroulage.
'Error 545 'Attributs d’objet non valides spécifiés à NtCreatePort ou attributs de port non valides spécifiés à NtConnectPort.
'Error 546 'La longueur du message passé à NtRequestPort ou NtRequestWaitReplyPort dépassait le maximum autorisé par le port.
'Error 547 'Tentative d’abaissement d’une limite de quota en dessous de l’usage en cours.
'Error 548 'Tentative d’attachement d’un périphérique déjà attaché à un autre périphérique.
'Error 549 'Tentative d’exécution d’une instruction à une adresse non alignée alors que le système hôte ne prend pas en charge les références d’instruction non alignées.
'Error 550 'La gestion des profils n’a pas démarré.
'Error 551 'La gestion des profils n’a pas été arrêtée.
'Error 552 'La liste ACL passée ne contient pas les informations minimales nécessaires.
'Error 553 'Impossible de lancer de nouveaux objets de profil car le nombre maximal a été atteint.
'Error 554 'Utilisé pour indiquer qu’une opération ne peut pas continuer sans blocage des E/S.
'Error 555 'Indique qu’un thread a tenté de s’arrêter lui-même par défaut (appel de NtTerminateThread avec NULL) et qu’il s’agissait du dernier thread dans le processus en cours.
'Error 556 'Si une erreur MM non définie dans le filtre standard FsRtl est renvoyée, elle est convertie vers l’une des erreurs suivantes, qui se trouvent nécessairement dans le filtre. Dans ce cas, des informations sont perdues bien que le filtre gère l’exception correcte
'Error 557 'Si une erreur MM non définie dans le filtre standard FsRtl est renvoyée, elle est convertie vers l’une des erreurs suivantes, qui se trouvent nécessairement dans le filtre. Dans ce cas, des informations sont perdues bien que le filtre gère l’exception correcte
'Error 558 'Si une erreur MM non définie dans le filtre standard FsRtl est renvoyée, elle est convertie vers l’une des erreurs suivantes, qui se trouvent nécessairement dans le filtre. Dans ce cas, des informations sont perdues bien que le filtre gère l’exception correcte
'Error 559 'Une table de fonction mal formée a été rencontrée lors d’une opération de déroulage.
'Error 560 'Indique que lors d’une tentative d’attribution de protection à un fichier ou un répertoire du système de fichiers, un des SID dans le descripteur de sécurité n’a pas pu être traduit en un GUID pouvant être stocké par le système de fichiers. Ceci fait échouer l
'Error 561 'Indique soit qu’on a tenté d’agrandir une LDT en définissant sa taille, soit que la taille n’était pas proportionnelle au nombre de sélecteurs.
'Error 563 'Indique que la valeur de départ pour les informations LDT n’était pas un multiple entier de la taille de sélecteur.
'Error 564 'Indique que l’utilisateur a fourni un descripteur non valide en tentant de configurer des descripteurs LDT.
'Error 565 'Indique qu’un processus a trop de threads pour accomplir l’action demandée. Par exemple, l’affectation d’un jeton principal ne peut s’accomplir que si un processus a zéro ou un thread.
'Error 566 'Tentative d’action sur un thread à l’intérieur d’un processus spécifique, alors que le thread spécifié n’est pas dans ce processus.
'Error 567 'Dépassement du quota de fichier d’échange.
'Error 568 'Le service Accès réseau ne peut pas démarrer car un autre service Accès réseau exécuté dans le domaine provoque un conflit avec le rôle spécifié.
'Error 569 'La base de données SAM sur un serveur Windows est nettement désynchronisée par rapport à l’exemplaire détenu par le contrôleur principal de domaine. Une resynchronisation complète est nécessaire.
'Error 570 'L’API NtCreateFile a échoué. Cette erreur ne doit jamais être renvoyée à une application : il s’agit d’un message réservé que le redirecteur Windows LAN Manager emploie dans ses sous-programmes de mappage d’erreurs internes.
'Error 571 '{Échec de privilège} Impossible de modifier les autorisations d’E/S du processus.
'Error 572 '{Arrêt de l’application par CTRL+C} L’application s’est terminée à la suite d’un CTRL+C.
'Error 573 '{Fichier système manquant} Le fichier système nécessaire %hs est incorrect ou manquant.
'Error 574 '{Erreur d’application} L’exception %s (0x
'Error 575 '{Erreur d’application} L’application n’a pas réussi à démarrer correctement (0x%lx). Cliquez sur OK pour fermer l’application.
'Error 576 '{Impossible de créer le fichier d’échange} La création du fichier d’échange %hs a échoué (%lx). La taille demandée était de %ld.
'Error 577 'Windows ne peut pas vérifier la signature numérique de ce fichier. Il est possible qu’une modification matérielle ou logicielle récente ait installé un fichier endommagé ou dont la signature est incorrecte, ou qu’il s’agisse d’un logiciel malveillant provenant
'Error 578 '{Pas de fichier d’échange spécifié} Aucun fichier d’échange n’a été spécifié dans la configuration du système.
'Error 579 '{EXCEPTION} Une application en mode réel a tenté d’exécuter une opération en virgule flottante alors qu’aucun processeur de virgule flottante n’est présent.
'Error 580 'Une opération de synchronisation de paire d’événements a été accomplie en utilisant l’objet paire d’événements client/serveur spécifique du thread, mais aucun objet paire d’événements n’était associé au thread.
'Error 581 'La configuration d’un serveur Windows est incorrecte.
'Error 582 'Rencontre d’un caractère non autorisé. Dans un jeu de caractères multi-octet, ceci inclut un octet en tête non suivi d’un octet en queue. Dans le jeu de caractères Unicode, ceci inclut les caractères 0xFFFF et 0xFFFE.
'Error 583 'Le caractère Unicode n’est pas défini dans le jeu de caractères Unicode installé sur le système.
'Error 584 'Impossible de créer le fichier d’échange sur une disquette.
'Error 585 'Le système BIOS n’a pas pu connecter une interruption du système au périphérique ou au bus auquel le périphérique est connecté.
'Error 586 'Cette opération n’est permise que pour le contrôleur principal du domaine.
'Error 587 'On a tenté d’acquérir un mutant tel que sa valeur de compteur maximale aurait été dépassée.
'Error 588 'On a accédé à un volume pour lequel un pilote de système de fichiers nécessaire n’a pas encore été chargé.
'Error 589 '{Défaillance d’un fichier du Registre} Le Registre ne peut pas charger la ruche (fichier) : %hs ou son journal ou sa copie. Elle est endommagée, absente ou protégée contre l’écriture.
'Error 590 '{Défaillance inattendue dans DebugActiveProcess} Une défaillance inattendue s’est produite lors du traitement d’une demande d’API DebugActiveProcess. Cliquez sur OK pour terminer le processus, ou sur Annuler pour ignorer l’erreur.
'Error 591 '{Erreur système irrécupérable} Le processus système %hs s’est terminé de façon inattendue avec l’état 0x
'Error 592 '{Données non acceptées} Le client TDI n’a pu traiter les données reçues lors d’une indication.
'Error 593 'NTVDM s’est heurté a une erreur matérielle.
'Error 594 '{Temporisation d’annulation expirée} Le pilote %hs n’a pas pu terminer une demande d’E/S annulée dans la temporisation allouée.
'Error 595 '{Erreur de correspondance de message-réponse} On a tenté de répondre à un message LPC, mais le thread spécifié par l’ID de client dans le message n’attendait pas ce message.
'Error 596 '{L’écriture différée a échoué} Windows n’a pas pu enregistrer les données du fichier %hs. Les données ont été perdues. Cette erreur peut être due à une panne de votre matériel ou de votre connexion réseau. Essayez d’enregistrer ce fichier à un autre emplacemen
'Error 597 'Le ou les paramètres passés au serveur dans la fenêtre de mémoire partagée client/serveur n’étaient pas valides. Trop de données ont dû être placées dans la fenêtre de mémoire partagée.
'Error 598 'Le flux n’est pas un flux minuscule.
'Error 599 'La demande doit être prise en charge par le code de débordement de pile.
'Error 600 'Les codes d’état OFS internes indiquent comment est prise en charge une opération d’allocation. Soit une nouvelle tentative d’allocation a eu lieu après le déplacement du nœud onode, soit le flux étendu est converti en un flux de plus grande taille.
'Error 601 'La tentative de trouver l’objet a trouvé un objet avec l’ID correspondant sur le volume mais il est hors de l’étendue du handle utilisé pour l’opération.
'Error 602 'Le tableau du compartiment doit être agrandi. Recommencez ensuite la transaction.
'Error 603 'Débordement de la zone tampon de tri utilisateur/noyau.
'Error 604 'La structure variante fournie contient des données non valides.
'Error 605 'La zone tampon spécifiée contient des données mal formées.
'Error 606 '{L’audit a échoué} Une tentative de génération d’un audit de sécurité a échoué.
'Error 607 'La résolution de la temporisation n’était pas fixée antérieurement par le processus en cours.
'Error 608 'Il n’y a pas assez d’informations de compte pour vous ouvrir une session.
'Error 609 '{Point d’entrée DLL non valide} La bibliothèque de liens dynamiques %hs n’est pas écrite correctement. Le pointeur de pile a été laissé dans un état incohérent. Le point d’entrée doit être déclaré en tant que WINAPI ou STDCALL. Sélectionnez OUI pour faire écho
'Error 610 '{Point d’entrée de rappel de service non valide} Le service %hs n’est pas écrit correctement. Le pointeur de pile a été laissé dans un état incohérent. Le point d’entrée de rappel doit être déclaré en tant que WINAPI ou STDCALL. Sélectionnez OK pour poursuivre
'Error 611 'Le système a détecté un conflit d’adresse IP avec un autre système sur le réseau
'Error 612 'Le système a détecté un conflit d’adresse IP avec un autre système sur le réseau
'Error 613 '{Taille du Registre faible} Le système a atteint la taille maximale autorisée pour la partie système du Registre. Les demandes de stockage supplémentaires seront ignorées.
'Error 614 'Impossible d’exécuter un service système de retour de rappel lorsqu’il n’y a pas de rappel actif.
'Error 615 'Le mot de passe fourni est trop court pour satisfaire à la stratégie de votre compte d’utilisateur. Choisissez un mot de passe plus long.
'Error 616 'La stratégie de votre compte d’utilisateur ne vous autorise pas à modifier les mots de passe trop fréquemment. Ceci est destiné à empêcher les utilisateurs de réutiliser un mot de passe familier, mais potentiellement découvert. Si vous pensez que votre mot de
'Error 617 'Vous avez tenté de remplacer votre mot de passe par un mot de passe que vous avez déjà utilisé. La stratégie de votre compte d’utilisateur ne le permet pas. Choisissez un mot de passe que vous n’avez pas déjà utilisé.
'Error 618 'Le format de compression spécifié n’est pas pris en charge.
'Error 619 'La configuration du profil matériel spécifiée n’est pas valide.
'Error 620 'Le chemin du périphérique du registre Plug-and-Play spécifié n’est pas valide.
'Error 621 'La liste de quota spécifiée est incohérente de façon interne avec son descripteur.
'Error 622 '{Avis d’évaluation de Windows} La période d’évaluation de cette installation de Windows a expiré. Ce système s’arrêtera dans une heure. Pour restaurer l’accès à cette installation de Windows, mettez à niveau cette installation avec une version sous licence de
'Error 623 '{Repositionnement de DLL système non autorisé} La DLL système %hs a été repositionnée en mémoire. L’application ne s’exécutera pas correctement. Le repositionnement a été effectué car la DLL %hs occupait une zone d’adresse réservée pour les DLL système de Wind
'Error 624 '{L’initialisation de la DLL a échoué} L’application n’a pas pu s’initialiser car la station de travail est en cours d’arrêt.
'Error 625 'Le processus de validation doit passer à l’étape suivante.
'Error 626 'Aucune autre correspondance n’existe pour l’énumération de l’index en cours.
'Error 627 'L’étendue n’a pas pu être ajoutée à la liste d’étendues en raison d’un conflit.
'Error 628 'Le processus serveur est en cours d’exécution sous un SID différent de celui nécessaire pour le client.
'Error 629 'Un groupe marqué en utilisation pour refus uniquement ne peut pas être activé.
'Error 630 '{EXCEPTION} Erreurs de virgules flottantes multiples.
'Error 631 '{EXCEPTION} Interruptions de virgules flottantes multiples.
'Error 632 'L’interface demandée n’est pas prise en charge.
'Error 633 '{Échec de la mise en attente système} Le pilote %hs ne prend pas en charge le mode de mise en attente. La mise à jour de ce pilote pourrait permettre la mise en attente du système.
'Error 634 'Le fichier système %1 était endommagé et a été remplacé.
'Error 635 '{Mémoire virtuelle minimale insuffisante} Votre système manque de mémoire virtuelle. Windows augmente la taille de votre fichier de pagination de mémoire virtuelle. Lors de cette opération, des demandes de mémoire pour certaines applications pourront être refu
'Error 636 'Un périphérique a été supprimé, une énumération doit donc être relancée.
'Error 637 '{Erreur système irrécupérable} L’image système %s n’est pas signée correctement. Le fichier a été remplacé par le fichier signé. Le système a été arrêté.
'Error 638 'Le périphérique ne peut pas être lancé sans un redémarrage.
'Error 639 'Il n’y a pas assez d’énergie pour terminer l’opération demandée.
'Error 640 'ERROR_MULTIPLE_FAULT_VIOLATION
'Error 641 'L’ordinateur est en train de s’arrêter.
'Error 642 'La suppression du processus DebugPort a été tentée, mais aucun port n’était associé avec ce processus.
'Error 643 'Cette version de Windows n’est pas compatible avec la version du comportement de la forêt, du domaine ou du contrôleur de domaine de l’annuaire.
'Error 644 'L’étendue spécifiée n’a pas été trouvée dans la liste d’étendues.
'Error 646 'Le pilote n’a pas été chargé car le système a démarré en mode sans échec.
'Error 647 'Le pilote n’a pas pu être chargé, car son appel de l’initialisation a échoué.
'Error 648 'Le "%hs" a rencontré une erreur lors de l’application de l’alimentation ou de la lecture de la configuration du périphérique. Cela peut être causé par une défaillance de votre matériel ou par une connexion de qualité médiocre.
'Error 649 'L’opération de création a échoué car le nom contient au moins un point de montage qui correspond à un volume auquel l’objet périphérique spécifié n’est pas connecté.
'Error 650 'Le paramètre d’objet périphérique est soit un objet périphérique non valide ou n’est pas connecté au volume spécifié par le nom de fichier.
'Error 651 'Une erreur de vérification d’ordinateur s’est produite. Vérifiez le journal d’événement système pour obtenir des informations supplémentaires.
'Error 652 'Une erreur [%2] s’est produite lors du traitement de la base de données des pilotes.
'Error 653 'La taille de la ruche système a dépassé sa limite.
'Error 654 'Le pilote n’a pas pu être chargé car une version précédente du pilote est encore en mémoire.
'Error 655 '{Service VSS} Veuillez patienter pendant que le service VSS prépare le volume %hs à l’hibernation.
'Error 656 'Le système n’a pas pu se mettre en veille prolongée (Le code d’erreur est %hs). La mise en veille prolongée doit être désactivée jusqu’au redémarrage du système.
'Error 657 'Le mot de passe spécifié est trop long pour répondre aux critères de la stratégie de votre compte d’utilisateur. Sélectionnez un mot de passe plus court.
'Error 665 'Impossible de terminer l’opération demandée du fait d’une limitation du système de fichiers.
'Error 668 'Un échec d’assertion s’est produit.
'Error 669 'Une erreur s’est produite dans le sous-système ACPI.
'Error 670 'Erreur d’assertion WOW.
'Error 671 'Un périphérique manque dans la table MPS du BIOS système. Ce périphérique ne sera pas utilisé. Contactez le fabricant de votre ordinateur pour une mise à jour du BIOS système.
'Error 672 'Un traducteur n’a pas pu traduire de ressources.
'Error 673 'Un traducteur IRQ n’a pas pu traduire de ressources.
'Error 674 'Le pilote %2 a renvoyé un ID non valide pour un périphérique enfant (%3).
'Error 675 '{Réveil du débogueur du noyau} Le débogueur système a été réveillé par une interruption.
'Error 676 '{Handles fermés} Des handles d’objets ont été fermés automatiquement à la suite de l’opération demandée.
'Error 677 '{Trop d’informations} La liste de contrôle d’accès spécifiée contenait plus d’informations que prévu.
'Error 678 'Cet état de niveau d’avertissement indique que l’état de transaction existe déjà pour la sous-arborescence de Registre, mais que la validation d’une transaction a été arrêtée antérieurement. La validation n’a pas eu lieu, mais n’a pas été annulée (il est donc
'Error 679 '{Changement de média} Le média a peut-être changé.
'Error 680 '{Substitution de GUID} Durant la traduction d’un identificateur global (GUID) vers un ID de sécurité Windows (SID), aucun préfixe GUID défini administrativement n’a été trouvé. Un préfixe de substitution a été utilisé, qui ne compromet pas la sécurité du systè
'Error 681 'L’opération de création s’est arrêtée après avoir atteint un lien symbolique.
'Error 682 'Un saut long a été exécuté.
'Error 683 'L’opération de demande Plug-and-Play n’a pas réussi.
'Error 684 'Une consolidation de trame a été exécutée.
'Error 685 '{La ruche du Registre a récupéré} La ruche du Registre (fichier): %hs a été endommagée et a récupéré. Certaines données sont peut-être perdues.
'Error 686 'L’application tente d’exécuter du code exécutable à partir du module %hs. La sécurité de ce module n’est pas garantie. Un module équivalent %hs est disponible. L’application doit-elle utiliser le module sécurisé %hs ?
'Error 687 'L’application charge du code exécutable à partir du module %hs. Ce module est sécurisé, mais il peut être incompatible avec des versions précédentes du système d’exploitation. Un module équivalent %hs est disponible. L’application doit-elle utiliser le module
'Error 688 'Le débogueur n’a pas traité l’exception.
'Error 689 'Le débogueur répondra plus tard.
'Error 690 'Le débogueur ne peut pas fournir de handle.
'Error 691 'Le débogueur a terminé le thread.
'Error 692 'Le débogueur a terminé le processus.
'Error 693 'Le débogueur a reçu une interruption Ctrl+C.
'Error 694 'Le débogueur a affiché une exception lors d’une interruption Ctrl+C.
'Error 695 'Le débogueur a reçu une exception RIP.
'Error 696 'Le débogueur a reçu une rupture de contrôle.
'Error 697 'Exception de communication de la commande de débogage.
'Error 698 '{Objet existant} Tentative de création d’un objet alors que le nom d’objet existait déjà.
'Error 699 '{Thread suspendu} Un thread a été arrêté alors qu’il était suspendu. Le thread a repris et la terminaison s’est poursuivie.
'Error 700 '{Image resituée} Impossible de mapper un fichier image à l’adresse spécifiée dans ce fichier image. Il faut corriger cette image localement.
'Error 701 'Cet état de niveau au caractère informatif indique qu’un état spécifié de transaction de sous-arborescence de Registre n’existe pas encore et doit être créé.
'Error 702 '{Chargement de segment} Une machine virtuelle DOS (VDM) charge, décharge ou déplace une image de segment de programme MS-DOS ou Win16. Une exception est activée afin qu’un débogueur puisse charger, décharger ou suivre des symboles et des points d’arrêt à l’int
'Error 703 '{Répertoire en cours non valide} Le processus ne peut pas basculer vers le répertoire de démarrage actuel %hs. Sélectionnez OK pour définir %hs en tant que répertoire en cours, ou sélectionnez Annuler pour quitter.
'Error 704 '{Lecture redondante} Pour satisfaire une demande de lecture, le système de fichiers à tolérance de pannes NT a lu les données demandées correctement dans une copie redondante. Cette erreur est causée par une défaillance de l’un des membres du volume à toléranc
'Error 705 '{Écriture redondante} Pour satisfaire une demande d’écriture, le système de fichiers à tolérance de pannes NT a écrit correctement une copie redondante. Cette erreur est causée par une défaillance de l’un des membres du volume à tolérance de pannes, qui n’a pa
'Error 706 '{Différence de types d’ordinateurs} Le fichier image %hs est valide, mais il correspond à un autre type d’ordinateur que celui-ci. Cliquez sur OK pour continuer, ou sur Annuler pour arrêter le chargement de la DLL.
'Error 707 '{Données partielles reçues} La couche Transport du réseau a renvoyé des données partielles à son client. Le reste sera envoyé plus tard.
'Error 708 '{Données expédiées reçues} La couche Transport du réseau a renvoyé à son client des données marquées expédiées par le système distant.
'Error 709 '{Données expédiées partielles reçues} La couche Transport du réseau a renvoyé des données partielles à son client, ces données étaient marquées expédiées par le système distant. Le reste sera envoyé plus tard.
'Error 710 '{Événement TDI terminé} L’indication d’événement TDI s’est terminée correctement.
'Error 711 '{Événement TDI en attente} L’indication d’événement TDI est entrée dans l’état attente.
'Error 712 'Vérification du système de fichiers sur %wZ
'Error 713 '{Sortie d’application irrécupérable} %hs
'Error 714 'La clé de Registre spécifiée est référencée par un handle prédéfini.
'Error 715 '{Page déverrouillée} La protection de page d’une page verrouillée a été modifiée en 'Accès refusé' et la page a été déverrouillée de la mémoire et du processus.
'Error 716 '%hs
'Error 717 '{Page verrouillée} Une des pages à verrouiller était déjà verrouillée.
'Error 718 'Message de l’application  '%1  '%2
'Error 719 'ERROR_ALREADY_WIN32
'Error 720 '{Différence de types d’ordinateurs} Le fichier image %hs est valide, mais correspond à un autre type d’ordinateur que celui-ci.
'Error 721 'Un rapport a été effectué et aucun thread n’a été trouvé pour être exécuté.
'Error 722 'L’indicateur réactivable d’une API de minuteur a été ignoré.
'Error 723 'L’arbitre a déféré l’arbitrage de ces ressources à son parent
'Error 724 'Impossible de démarrer le périphérique CardBus inséré du fait d’une erreur de configuration dans « %hs ».
'Error 725 'Les processeurs ne sont pas tous aux mêmes niveaux de révision dans ce système multiprocesseurs. Pour utiliser tous les processeurs, le système d’exploitation se restreint au processeur le moins puissant du système. Si des problèmes se produisent avec ce systè
'Error 726 'Le système a été mis en veille prolongée.
'Error 727 'Le système est sorti de la veille prolongée.
'Error 728 'Windows a détecté que le microprogramme système (BIOS) a été mis à jour [date du microprogramme précédent  '%2, date du microprogramme actuel  '%3].
'Error 729 'Un pilote de périphériques perd des pages E/S verrouillées ce qui entraîne une dégradation du système. Le système a automatiquement activé le suivi du code afin d’essayer d’attraper le coupable.
'Error 730 'Le système a été mis en éveil
'Error 731 'ERROR_WAIT_1
'Error 732 'ERROR_WAIT_2
'Error 733 'ERROR_WAIT_3
'Error 734 'ERROR_WAIT_63
'Error 735 'ERROR_ABANDONED_WAIT_0
'Error 736 'ERROR_ABANDONED_WAIT_63
'Error 737 'ERROR_USER_APC
'Error 738 'ERROR_KERNEL_APC
'Error 739 'ERROR_ALERTED
'Error 740 'L’opération demandée nécessite une élévation.
'Error 741 'Le Gestionnaire d’objets doit effectuer une nouvelle analyse puisque le nom du fichier a donné lieu à un lien symbolique.
'Error 742 'Une opération ouvrir/créer a été effectuée bien qu’une interruption de verrou optionnel soit en cours.
'Error 743 'Un nouveau volume a été monté par un système de fichiers.
'Error 744 'Cet état de niveau de succès indique que l’état de transaction existe déjà pour la sous-arborescence de Registre, mais qu’une validation de transaction a été abandonnée antérieurement. La validation a été menée à bien maintenant.
'Error 745 'Ceci indique qu’une demande de notification de modification a été exécutée en raison de la fermeture du handle qui a émis cette demande.
'Error 746 '{Erreur de connexion via la couche transport primaire} On a tenté de se connecter au serveur distant %hs via la couche transport primaire, mais la connexion a échoué. L’ordinateur s’est connecté via une couche transport secondaire.
'Error 747 'Le défaut de page était un défaut de transition.
'Error 748 'Le défaut de page était une erreur de demande nulle.
'Error 749 'Le défaut de page était une erreur de demande nulle.
'Error 750 'Le défaut de page était une erreur de demande nulle.
'Error 751 'Le défaut de page était satisfait en lisant sur un périphérique de stockage secondaire.
'Error 752 'La page mise en cache était verrouillée pendant l’opération.
'Error 753 'Il y a un fichier de vidage sur incident dans le fichier d’échange.
'Error 754 'La zone tampon spécifiée ne contient que des zéros.
'Error 755 'Le Gestionnaire d’objets doit effectuer une nouvelle analyse puisque le nom du fichier a donné lieu à un lien symbolique.
'Error 756 'Le périphérique a réussi un arrêt de requête et ses besoins en ressources ont changé.
'Error 757 'Le traducteur a traduit ces ressources dans l’espace global et aucune traduction ne devrait être effectuée désormais.
'Error 758 'Un processus en cours d’arrêt n’a pas de threads à terminer.
'Error 759 'Le processus spécifié ne fait pas partie d’une tâche.
'Error 760 'Le processus spécifié fait partie d’une tâche.
'Error 761 '{Service VSS} Le système est maintenant prêt à hiberner.
'Error 762 'Un système de fichiers ou un pilote de filtre du système de fichiers a terminé avec succès une opération FsFilter.
'Error 763 'Le vecteur d’interruption spécifié était déjà connecté.
'Error 764 'Le vecteur d’interruption spécifié est toujours connecté.
'Error 765 'Une opération est bloquée pendant l’attente d’un verrou facultatif.
'Error 766 'Le débogueur a traité l’exception.
'Error 767 'Le débogueur a continué.
'Error 768 'Une exception s’est produite dans un rappel en mode utilisateur et la trame en rappel du noyau doit être supprimée.
'Error 769 'La compression est désactivée pour ce volume.
'Error 770 'Le fournisseur de données ne peut pas récupérer vers l’arrière via un jeu de résultats.
'Error 771 'Le fournisseur de données ne peut pas faire défiler en arrière via un jeu de résultats.
'Error 772 'Le fournisseur de données requiert que les données précédemment récupérées soient libérées avant de demander davantage de données.
'Error 773 'Le fournisseur de données n’a pas pu interpréter les indicateurs définis pour une liaison de colonne dans un accesseur.
'Error 774 'Une ou plusieurs erreurs se sont produites lors du traitement de la demande.
'Error 775 'L’implémentation n’est pas capable d’effectuer la demande.
'Error 776 'Le client d’un composant a demandé une opération qui n’est pas valide compte tenu de l’état de l’instance du composant.
'Error 777 'Impossible d’analyser un numéro de version.
'Error 778 'Position de début de l’itérateur non valide.
'Error 779 'Le matériel a signalé une erreur de mémoire irrécupérable.
'Error 780 'L’opération tentée nécessitait l’activation de la réparation spontanée.
'Error 781 'Le segment du Bureau a rencontré une erreur lors de l’allocation de mémoire à la session. Pour plus d’informations, voir le journal des événements système.
'Error 782 'L’état de l’alimentation du système passe de %2 à %3.
'Error 783 'L’état de l’alimentation du système passe de %2 à %3 mais pourrait passer à %4.
'Error 784 'Un thread est en cours de distribution avec une EXCEPTION MCA du fait de MCA.
'Error 785 'L’accès à %1 est analysé par la règle de stratégie %2.
'Error 786 'L’accès à %1 a été restreint par votre administrateur par la règle de stratégie %2.
'Error 787 'Un fichier de mise en veille prolongée valide a été invalidé et doit être abandonné.
'Error 788 '{Échec d’écriture différée} Windows n’a pas pu enregistrer toutes les données pour le fichier %hs ; les données ont été perdues. Cette erreur peut être due à des problèmes de connectivité réseau. Essayez d’enregistrer ce fichier à un autre emplacement.
'Error 789 '{Échec d’écriture différée} Windows n’a pas pu enregistrer toutes les données pour le fichier %hs ; les données ont été perdues. Cette erreur a été renvoyée par le serveur où réside le fichier. Essayez d’enregistrer ce fichier à un autre emplacement.
'Error 790 '{Échec d’écriture différée} Windows n’a pas pu enregistrer toutes les données du fichier %hs ; les données ont été perdues. Cette erreur peut se produire si le périphérique est retiré ou si le support est protégé en écriture.
'Error 791 'Les ressources requises pour ce périphérique sont en conflit avec la table MCFG.
'Error 792 'La réparation du volume ne peut pas aboutir lorsque celui-ci est en ligne. Prévoyez de mettre le volume hors connexion afin de pouvoir le réparer.
'Error 793 'La réparation du volume n’a pas abouti.
'Error 794 'Un des journaux des défaillances de volume est saturé. Les défaillances supplémentaires qui seront éventuellement détectées ne seront pas enregistrées dans le journal.
'Error 795 'Un des journaux des défaillances de volume est endommagé de façon interne et doit être recréé. Il se peut que des défaillances non détectées se trouvent dans le volume et que ce dernier doive être analysé.
'Error 796 'Un des journaux des défaillances de volume ne peut faire l’objet d’aucune opération du fait de son indisponibilité.
'Error 797 'Un des journaux des défaillances de volume a été supprimé alors qu’il contenait encore des enregistrements de défaillance. Des défaillances ont été détectées dans le volume, qui doit être analysé.
'Error 798 'Un des journaux des défaillances de volume a été effacé par chkdsk et ne contient plus de défaillances réelles.
'Error 799 'Il existe des fichiers orphelins sur le volume, mais ils n’ont pas pu être récupérés du fait de l’impossibilité de créer de nouveaux noms dans le répertoire de récupération. Les fichiers doivent être déplacés du répertoire de récupération.
'Error 800 'Le verrou optionnel qui était associé à ce handle est maintenant associé à un autre handle.
'Error 801 'Impossible d’octroyer un verrou optionnel du niveau demandé. Un verrou optionnel de niveau inférieur est peut-être disponible.
'Error 802 'L’opération n’a pas abouti car elle aurait entraîné la rupture d’un verrou optionnel. L’appelant a demandé à ce que les verrous optionnels existants ne soient pas rompus.
'Error 803 'Le handle auquel ce verrou optionnel était associé a été fermé. Le verrou optionnel est maintenant rompu.
'Error 804 'L’entrée de contrôle d’accès spécifiée ne contient pas de condition.
'Error 805 'L’entrée de contrôle d’accès spécifiée contient une condition non valide.
'Error 806 'L’accès au descripteur de fichier spécifié a été révoqué.
'Error 807 '{Image resituée} Un fichier image a été mappé à une adresse différente de celle spécifiée dans le fichier image, mais des corrections seront appliquées automatiquement sur l’image.
'Error 808 'Impossible d’effectuer l’opération de lecture ou d’écriture dans un fichier chiffré, car celui-ci n’a pas été ouvert pour permettre l’accès aux données.
'Error 809 'L 'optimisation des métadonnées de fichier est déjà en cours.
'Error 810 'Échec de l'opération demandée, car l'opération de quota est toujours en cours.
'Error 811 'L 'accès au descripteur spécifié a été révoqué.
'Error 812 'La fonction de rappel doit être appelée en ligne.
'Error 813 'Les ID de jeu de processeurs spécifiés ne sont pas valides.
'Error 814 'L 'enclave spécifiée n'a pas encore été achevée.
'Error 994 'L’accès à l’attribut étendu (EA) a été refusé.
'Error 995 'L’opération d’entrée/sortie a été abandonnée en raison de l’arrêt d’un thread ou à la demande d’une application.
'Error 996 'L’événement d’entrée/sortie avec chevauchement n’est pas dans un état signalé.
'Error 997 'Une opération d’entrée/sortie avec chevauchement est en cours d’exécution.
'Error 998 'L’accès à cet emplacement de la mémoire n’est pas valide.
'Error 999 'Erreur lors d’une opération de pagination.
'Error 1001 'Récurrence trop profonde ; la pile a débordé.
'Error 1002 'La fenêtre ne peut pas agir sur le message envoyé.
'Error 1003 'Impossible d’accomplir cette fonction.
'Error 1004 'Indicateurs non valides.
'Error 1005 'Le volume ne contient pas de système de fichiers connu. Vérifiez si tous les pilotes de système de fichiers nécessaires sont chargés et si le volume n’est pas endommagé.
'Error 1006 'Le fichier ouvert n’est plus valide car le volume qui le contient a été endommagé de manière externe.
'Error 1007 'L’opération demandée ne peut pas s’accomplir en mode plein écran.
'Error 1008 'Tentative de référence à un jeton qui n’existe pas.
'Error 1009 'Le Registre de configuration est endommagé.
'Error 1010 'Clé du Registre de configuration non valide.
'Error 1011 'Impossible d’ouvrir la clé du Registre de configuration.
'Error 1012 'Impossible de lire la clé du Registre de configuration.
'Error 1013 'Impossible d’écrire la clé du Registre de configuration.
'Error 1014 'Un des fichiers dans la base de données du Registre a dû être restauré au moyen d’un journal ou d’une copie. La restauration a réussi.
'Error 1015 'Le Registre est endommagé. La structure d’un des fichiers contenant des données du Registre ou l’image de la mémoire système du fichier sont endommagées, ou le fichier ne peut être trouvé car une copie ou un journal sont absents ou endommagés.
'Error 1016 'Une opération d’E/S démarrée par le Registre a échoué irrémédiablement. Le Registre n’a pas pu lire ni écrire les informations de l’un des fichiers contenant son image système, ni vider ce fichier.
'Error 1017 'Le système a tenté de charger ou de restaurer un fichier dans le Registre, mais le fichier spécifié n’a pas un format de fichier du Registre.
'Error 1018 'Tentative d’opération non autorisée sur une clé du Registre marquée pour suppression.
'Error 1019 'Le système n’a pas pu allouer l’espace demandé dans un journal du Registre.
'Error 1020 'Impossible de créer un lien symbolique dans une clé du Registre qui a déjà des sous-clés ou des valeurs.
'Error 1021 'Impossible de créer une sous-clé stable sous une clé parente volatile.
'Error 1022 'Une requête de notification de changement est en cours d’achèvement et une information n’est pas retournée dans le tampon de l’appelant. L’appelant doit énumérer les fichiers pour détecter les changements.
'Error 1051 'Un ordre d’arrêt a été envoyé à un service dont plusieurs autres services en cours d’exécution dépendent.
'Error 1052 'La commande demandée n’est pas valide pour ce service.
'Error 1053 'Le service n’a pas répondu assez vite à la demande de lancement ou de contrôle.
'Error 1054 'Un thread n’a pas pu être créé pour le service.
'Error 1055 'La base de données des services est verrouillée.
'Error 1056 'Une instance du service s’exécute déjà.
'Error 1057 'Le nom de compte n’est pas valide ou n’existe pas, ou le mot de passe n’est pas valide pour le nom de compte spécifié.
'Error 1058 'Le service ne peut pas être démarré parce qu’il est désactivé ou qu’aucun périphérique activé ne lui est associé.
'Error 1059 'Spécification d’une dépendance circulaire de services.
'Error 1060 'Le service spécifié n’existe pas en tant que service installé.
'Error 1061 'Le service ne peut pas accepter des commandes en ce moment.
'Error 1062 'Le service n’a pas été démarré.
'Error 1063 'Le processus de service n’a pas pu se connecter au contrôleur de service.
'Error 1064 'Une exception s’est produite dans le service lors du traitement de la commande.
'Error 1065 'La base de données spécifiée n’existe pas.
'Error 1066 'Le service a renvoyé un code d’erreur qui lui est spécifique.
'Error 1067 'Le processus s’est arrêté inopinément.
'Error 1068 'Le service ou le groupe de dépendance n’a pas pu démarrer.
'Error 1069 'L’échec d’une ouverture de session a empêché le démarrage du service.
'Error 1070 'Après démarrage, le service s’est arrêté dans un état d’attente.
'Error 1071 'Le verrou de base de données des services spécifié n’est pas valide.
'Error 1072 'Le service spécifié a été marqué pour suppression.
'Error 1073 'Le service spécifié existe déjà.
'Error 1074 'Le système s’exécute actuellement en utilisant la dernière configuration correcte connue.
'Error 1075 'Le service de dépendance n’existe pas ou a été marqué pour suppression.
'Error 1076 'Le démarrage actuel a déjà été accepté pour une utilisation en tant que dernière configuration correcte connue.
'Error 1077 'Aucune tentative de lancement du service n’a eu lieu depuis le dernier démarrage.
'Error 1078 'Ce nom est déjà utilisé en tant que nom de service ou nom de service complet.
'Error 1079 'Le compte spécifié pour ce service est différent du compte spécifié pour d’autres services s’exécutant dans le même processus.
'Error 1080 'Des actions d’échec ne peuvent être définies que pour des services Win32, pas pour des pilotes.
'Error 1081 'Ce service s’exécute dans le même processus que le Gestionnaire de contrôle de service. Pour cette raison, le Gestionnaire de contrôle de service ne peut agir si ce processus du service se termine de manière inattendue.
'Error 1082 'Aucun programme de récupération n’a été configuré pour ce service.
'Error 1083 'Le programme dans lequel ce service doit s’exécuter n’implémente pas le service.
'Error 1084 'Ce service ne peut pas être démarré en mode sans échec
'Error 1100 'La fin de bande physique a été atteinte.
'Error 1101 'Une marque de fichier a été atteinte lors d’un accès à la bande.
'Error 1102 'Rencontre du début de bande ou de partition.
'Error 1103 'La fin d’un groupe de fichiers a été atteinte lors d’un accès à la bande.
'Error 1104 'Plus de données sur la bande.
'Error 1105 'Impossible de partitionner la bande.
'Error 1106 'La taille de bloc actuelle est incorrecte pour un accès à une nouvelle bande d’une partition multivolume.
'Error 1107 'Informations de partition de bande introuvables lors du chargement d’une bande.
'Error 1108 'Impossible de verrouiller le mécanisme d’éjection du média.
'Error 1109 'Impossible de décharger le média.
'Error 1110 'Le média utilisé dans le lecteur a peut-être changé.
'Error 1111 'Le bus E/S a été réinitialisé.
'Error 1112 'Pas de média dans le lecteur .
'Error 1113 'Il n’y a pas de caractère correspondant au caractère Unicode dans la page de codes multi-octet cible.
'Error 1114 'Une routine d’initialisation d’une bibliothèque de liens dynamiques (DLL) a échoué.
'Error 1115 'Un arrêt système est en cours.
'Error 1116 'Le système n’étant pas en cours d’arrêt, il est impossible d’annuler l’arrêt du système.
'Error 1117 'Impossible de satisfaire à la demande en raison d’une erreur de périphérique d’E/S.
'Error 1118 'Échec de l’initialisation de périphérique série. Le pilote série sera déchargé.
'Error 1119 'Impossible d’ouvrir un périphérique qui partageait une interruption (IRQ) avec d’autres périphériques. Au moins un des autres périphériques utilisant cette IRQ était déjà ouvert.
'Error 1120 'Une opération d’entrée/sortie série a été achevée par une autre écriture sur le port série port. (Le compteur IOCTL_SERIAL_XOFF_COUNTER a atteint zéro.)
'Error 1121 'Une opération d’entrée/sortie série a été achevée car le délai d’attente a expiré. (Le compteur IOCTL_SERIAL_XOFF_COUNTER n’a pas atteint zéro.)
'Error 1122 'Aucune marque d’adresse d’ID n’a été trouvée sur la disquette.
'Error 1123 'Discordance entre le champ d’ID de secteur de la disquette et l’adresse de piste du contrôleur du lecteur de disquette.
'Error 1124 'Le contrôleur de disquette a signalé une erreur non reconnue par le pilote de lecteur de disquette.
'Error 1125 'Le contrôleur du lecteur de disquettes a renvoyé des résultats incohérents dans ses registres.
'Error 1126 'Lors d’un accès au disque dur, une opération de recalibrage a échoué malgré plusieurs essais.
'Error 1127 'Lors d’un accès au disque dur, une opération disque a échoué malgré plusieurs essais.
'Error 1128 'Lors d’un accès au disque dur, une réinitialisation nécessaire du contrôleur de disque s’est avérée impossible.
'Error 1129 'Rencontre de la fin de bande physique.
'Error 1130 'Mémoire insuffisante sur le serveur pour traiter cette commande.
'Error 1131 'Une étreinte fatale potentielle a été détectée.
'Error 1132 'L’adresse de base ou l’Offset dans le fichier n’est pas aligné correctement.
'Error 1140 'Une tentative de modification de l’état de l’alimentation du système s’est heurtée au veto d’une autre application ou d’un autre pilote.
'Error 1141 'Le BIOS a tenté vainement de modifier l’état de l’alimentation du système.
'Error 1142 'Une tentative de création d’un nombre de liens supérieur au nombre maximal autorisé par le système de fichiers a été effectuée.
'Error 1150 'Le programme spécifié nécessite une version de Windows plus récente.
'Error 1151 'Le programme spécifié n’est pas un programme Windows ou MS-DOS.
'Error 1152 'Impossible de démarrer plusieurs instances du programme spécifié.
'Error 1153 'Le programme spécifié a été écrit pour une version antérieure de Windows.
'Error 1154 'Une des librairies nécessaires à l’exécution de cette application est endommagée.
'Error 1155 'Aucune application n’est associée au fichier spécifié pour cette opération.
'Error 1156 'Une erreur s’est produite lors de l’envoi de la commande à l’application.
'Error 1157 'Une des librairies nécessaires à l’exécution de cette application n’a pu être trouvée.
'Error 1158 'Le processus actuel a utilisé tout son lot alloué par le système de descripteurs pour les objets du Gestionnaire de fenêtre.
'Error 1159 'Le message ne peut être utilisé qu’avec des opérations synchrones.
'Error 1160 'L’élément source indiqué n’a pas de média.
'Error 1161 'L’élément destination indiqué contient déjà un média.
'Error 1162 'L’élément indiqué n’existe pas.
'Error 1163 'L’élément indiqué fait partir d’un magazine qui n’est pas présent.
'Error 1164 'Le périphérique indiqué nécessite une réinitialisation en raison d’erreurs matérielles.
'Error 1165 'Le périphérique a indiqué qu’un nettoyage est requis avant que d’autres opérations ne soient tentées.
'Error 1166 'Le périphérique a indiqué que sa porte est ouverte.
'Error 1167 'Le périphérique n’est pas connecté.
'Error 1168 'Élément introuvable.
'Error 1169 'Aucune correspondance pour la clé indiquée dans l’index.
'Error 1170 'L’ensemble des propriétés spécifiées n’existe pas sur l’objet.
'Error 1171 'Le point passé à GetMouseMovePoints n’est pas dans la mémoire tampon.
'Error 1172 'Le service de traçage (station de travail) n’est pas en cours d’exécution.
'Error 1173 'L’identificateur de volume n’a pas pu être trouvé.
'Error 1175 'Impossible de supprimer le fichier à remplacer.
'Error 1176 'Impossible de déplacer le fichier de remplacement vers le fichier à remplacer. Le fichier à remplacer a conservé son nom d’origine.
'Error 1177 'Impossible de déplacer le fichier de remplacement vers le fichier à remplacer. Le fichier à remplacer a été renommé en utilisant le nom de sauvegarde.
'Error 1178 'Le journal de modification du volume est en cours de suppression.
'Error 1179 'Le journal de modification du volume n’est pas actif.
'Error 1180 'Un fichier a été trouvé, mais il ne s’agit peut-être pas du bon fichier.
'Error 1181 'L’entrée du journal a été supprimée du journal.
'Error 1183 'Les paramètres volatils du vérificateur de pilotes ne peuvent pas être configurés lorsque CFG est activé.
'Error 1184 'Tentative d’accès à une partition en cours de terminaison.
'Error 1190 'Un arrêt du système a déjà été programmé.
'Error 1191 'Impossible d’initier l’arrêt du système car d’autres utilisateurs ont ouvert une session sur l’ordinateur.
'Error 1200 'Le nom de périphérique spécifié n’est pas valide.
'Error 1201 'Le périphérique n’est pas connecté actuellement, mais il s’agit d’une connexion mémorisée.
'Error 1202 'Le nom de périphérique local a une connexion mémorisée sur une autre ressource réseau.
'Error 1203 'Le chemin réseau est erroné ou n’existe pas, ou le fournisseur réseau n’est pas disponible à présent. Entrez le chemin de nouveau, ou contactez votre administrateur réseau.
'Error 1204 'Le nom de logiciel réseau spécifié n’est pas valide.
'Error 1205 'Impossible d’ouvrir le profil de connexions réseau.
'Error 1206 'Le profil de connexions réseau est endommagé.
'Error 1207 'Impossible d’énumérer un objet qui n’est pas un conteneur.
'Error 1208 'Une erreur étendue s’est produite.
'Error 1209 'Le format du nom de groupe spécifié n’est pas valide.
'Error 1210 'Le format du nom d’ordinateur spécifié n’est pas valide.
'Error 1211 'Le format du nom d’événement spécifié n’est pas valide.
'Error 1212 'Le format du nom de domaine spécifié n’est pas valide.
'Error 1213 'Le format du nom de service spécifié n’est pas valide.
'Error 1214 'Le format du nom réseau spécifié n’est pas valide.
'Error 1215 'Le format du nom de partage spécifié n’est pas valide.
'Error 1216 'Le format du mot de passe spécifié n’est pas valide.
'Error 1217 'Le format du nom de message spécifié n’est pas valide.
'Error 1218 'Le format de la destination de message spécifiée n’est pas valide.
'Error 1219 'Plusieurs connexions à un serveur ou à une ressource partagée par le même utilisateur, en utilisant plus d’un nom utilisateur, ne sont pas autorisées. Supprimez toutes les connexions précédentes au serveur ou à la ressource partagée et recommencez.
'Error 1220 'Une tentative d’établissement de session avec un serveur réseau a eu lieu alors que le nombre maximal de sessions sur ce serveur était déjà dépassé.
'Error 1221 'Le nom du groupe de travail ou de domaine est déjà utilisé par un autre ordinateur sur le réseau.
'Error 1222 'Soit il n’y a pas de réseau, soit le réseau n’a pas démarré.
'Error 1223 'L’opération a été annulée par l’utilisateur.
'Error 1224 'L’opération demandée n’a pu s’accomplir sur un fichier ayant une section mappée utilisateur ouverte.
'Error 1225 'Le système distant a refusé la connexion réseau.
'Error 1226 'La connexion réseau a été fermée gracieusement.
'Error 1227 'Le point de terminaison du transport réseau a déjà une adresse qui lui est associée.
'Error 1228 'Une adresse n’a pas encore été associée au point de terminaison du réseau.
'Error 1229 'Une opération a été tentée sur une connexion réseau qui n’existe pas.
'Error 1230 'Une opération incorrecte a été tentée sur une connexion réseau active.
'Error 1231 'L’emplacement réseau ne peut pas être atteint. Pour obtenir des informations concernant la résolution des problèmes du réseau, consultez l’aide de Windows.
'Error 1232 'L’emplacement réseau ne peut pas être atteint. Pour obtenir des informations concernant la résolution des problèmes du réseau, consultez l’aide de Windows.
'Error 1233 'L’emplacement réseau ne peut pas être atteint. Pour obtenir des informations concernant la résolution des problèmes du réseau, consultez l’aide de Windows.
'Error 1234 'Aucun service n’opère sur le point de terminaison du réseau de destination du système distant.
'Error 1235 'La requête a été interrompue.
'Error 1236 'La connexion réseau a été arrêtée par le système local.
'Error 1237 'L’opération n’a pas pu être terminée. Un nouvel essai doit être effectué.
'Error 1238 'Une connexion au serveur n’a pas pu être effectuée car le nombre maximal de connexions simultanées a été atteint.
'Error 1239 'Tentative d’ouverture de session pendant un créneau horaire ou un jour non autorisé pour ce compte.
'Error 1240 'Le compte n’est pas autorisé à se connecter depuis cette station.
'Error 1241 'L’adresse réseau n’a pas pu être utilisée pour l’opération requise.
'Error 1242 'Le service est déjà inscrit.
'Error 1243 'Le service spécifié n’existe pas.
'Error 1244 'L’opération demandée n’a pas été effectuée car l’utilisateur n’a pas été authentifié.
'Error 1245 'L’opération demandée n’a pas été effectuée car l’utilisateur n’est pas connecté au réseau. Le service spécifié n’existe pas.
'Error 1246 'Continuer le travail en cours.
'Error 1247 'Tentative de réalisation d’une opération d’initialisation alors que l’initialisation a déjà eu lieu.
'Error 1248 'Aucun périphérique supplémentaire disponible .
'Error 1249 'Le site spécifié n’existe pas.
'Error 1250 'Un contrôleur de domaine avec le nom spécifié existe déjà.
'Error 1251 'Cette opération n’est prise en charge que lorsque vous êtes connecté au serveur.
'Error 1252 'La structure de la stratégie de groupe devrait appeler l’extension même lorsqu’il n’y a pas de modification.
'Error 1253 'L’utilisateur spécifié ne possède pas un profil valide.
'Error 1254 'Cette opération n’est pas prise en charge sur un ordinateur exécutant Windows Server 2003 pour Small Business Server
'Error 1255 'Le serveur est en cours d’arrêt.
'Error 1256 'Le système distant n’est pas disponible. Pour obtenir des informations à propos du dépannage réseau, consulter l’Aide Windows.
'Error 1257 'L’identificateur de sécurité fourni ne provient pas d’un compte de domaine.
'Error 1258 'L’identificateur de sécurité fourni n’a pas de composant de domaine.
'Error 1259 'Le dialogue AppHelp a été annulé ce qui empêche le démarrage de l’application.
'Error 1260 'Ce programme est bloqué par une stratégie de groupe. Pour plus d’informations, contactez votre administrateur système.
'Error 1261 'Un programme tente d’utiliser une valeur de Registre non valide, normalement causée par un Registre non initialisé. Cette erreur est spécifique aux systèmes Itanium.
'Error 1262 'Le partage est actuellement hors ligne ou n’existe pas.
'Error 1263 'Le protocole Kerberos a rencontré une erreur lors de la validation du certificat KDC pendant l’ouverture de session par carte à puce. Ouvrez le journal des événements pour plus d’informations.
'Error 1264 'Le protocole Kerberos a rencontré une erreur lors de la tentative d’utilisation du sous-système de carte à puce.
'Error 1265 'Le système ne parvient pas à contacter un contrôleur de domaine pour traiter la demande d’authentification. Recommencez ultérieurement.
'Error 1271 'L’ordinateur était verrouillé et ne peut pas être arrêté sans l’option forcer.
'Error 1272 'Vous ne pouvez pas accéder à ce dossier partagé, car les stratégies de sécurité de votre entreprise bloquent l'accès invité non authentifié. Ces stratégies contribuent à la protection de votre pc contre les périphériques non sécurisés ou malveillants du réseau
'Error 1273 'Un rappel d’application définie a renvoyé des données non valides au moment de l’appel .
'Error 1274 'La structure de stratégie de groupe devrait appeler l’extension dans l’actualisation de la stratégie en premier plan synchrone.
'Error 1275 'Le chargement du pilote a été bloqué
'Error 1276 'Une bibliothèque de liens dynamiques (DLL) faisait référence à un module qui n’est ni une DLL ni l’image exécutable d’un processus.
'Error 1277 'Windows ne peut pas ouvrir ce programme car il a été désactivé.
'Error 1278 'Windows ne peut pas ouvrir ce programme car le système d’application de la licence a été falsifié ou est corrompu.
'Error 1279 'Une récupération de transaction a échoué.
'Error 1280 'Le thread actuel a déjà été converti en fibre.
'Error 1281 'Le thread actuel a déjà été converti à partir d’une fibre.
'Error 1282 'Le système a détecté la saturation de la mémoire tampon dans cette application. Cette saturation pourrait permettre à un utilisateur mal intentionné de prendre le contrôle de cette application.
'Error 1283 'Les données présentes dans l’un des paramètres est plus que ce sur quoi la fonction peut travailler.
'Error 1284 'La tentative d’effectuer une opération sur un objet de débogage a échoué car l’objet est situé dans le processus devant être supprimé.
'Error 1285 'Une tentative de report de chargement d’un fichier DLL ou d’obtention d’une adresse de fonction dans un fichier DLL en attente de chargement a échoué.
'Error 1286 '%1 est une application 16 bits. Vous ne disposez pas des autorisations pour exécuter des applications 16 bits. Vérifiez vos autorisations avec votre administrateur système.
'Error 1287 'Il n’y a pas suffisamment d’informations pour identifier la cause de la défaillance.
'Error 1288 'Le paramètre passé à une fonction C runtime est incorrect.
'Error 1289 'L’opération a eu lieu au-delà de la longueur de données valide du fichier.
'Error 1290 'Le démarrage du service a échoué car un ou plusieurs services appartenant au même processus possèdent un paramètre de type SID de service incompatible. Un service possédant un type SID de service restreint ne peut coexister dans le même processus qu’avec des s
'Error 1291 'Le processus hébergeant le pilote de ce périphérique a été fermé.
'Error 1292 'Une opération a tenté de dépasser une limite définie dans l’implémentation.
'Error 1293 'Le processus cible ou le processus contenant le thread cible est sécurisé.
'Error 1294 'Le client de notification de service est trop en retard par rapport à l’état actuel des services de l’ordinateur.
'Error 1295 'L’opération de fichier demandée a échoué car le quota de stockage a été dépassé. Pour libérer de l’espace disque, déplacez les fichiers dans un autre emplacement ou supprimez les fichiers superflus. Pour plus d’informations, contactez votre administrateur syst
'Error 1296 'L’opération de fichier demandée a échoué car la stratégie de stockage bloque ce type de fichier. Pour plus d’informations, contactez votre administrateur système.
'Error 1297 'Un privilège exigé par le service pour fonctionner correctement n’existe pas dans la configuration du compte du service. Vous pouvez utiliser le composant logiciel enfichable Services (services.msc) de la console de gestion Microsoft pour afficher la configura
'Error 1298 'Un thread impliqué dans cette opération semble ne pas répondre.
'Error 1299 'Indique qu’un ID de sécurité particulier n’est sans doute pas affecté en tant qu’étiquette d’un objet.
'Error 1300 'L’appelant ne bénéficie pas de tous les privilèges ou groupes référencés.
'Error 1301 'Un mappage entre des noms de comptes et des ID de sécurité n’a été effectué.
'Error 1302 'Aucune limite de quotas système n’a été définie spécifiquement pour ce compte.
'Error 1303 'Aucune clé de chiffrement n’est disponible. Une clé de chiffrement connue a été renvoyée.
'Error 1304 'Le mot de passe est trop complexe pour être converti en un mot de passe LAN Manager. Le mot de passe LAN Manager renvoyé est une chaîne nulle.
'Error 1305 'Numéro de version inconnu.
'Error 1306 'Indique deux numéros de version incompatibles.
'Error 1307 'Cet ID de sécurité ne peut être défini en tant que propriétaire de cet objet.
'Error 1308 'Cet ID de sécurité ne peut être défini en tant que groupe principal d’un objet.
'Error 1309 'Un thread qui n’utilise pas actuellement l’identité d’un client a tenté d’agir sur un jeton d’emprunt d’identité.
'Error 1310 'Le groupe ne peut être désactivé.
'Error 1311 'Nous n’avons pas pu vous connecter avec ces informations d’identification, car votre domaine n’est pas disponible. Vérifiez que votre appareil est connecté au réseau de votre organisation, puis réessayez. Si vous vous connectiez sur cet appareil avec d’autres
'Error 1312 'Une ouverture de session spécifiée n’existe pas. Elle est peut-être déjà terminée.
'Error 1313 'Un privilège spécifié n’existe pas.
'Error 1314 'Le client ne dispose pas d’un privilège nécessaire.
'Error 1315 'Le nom fourni n’est pas un nom de compte formé correctement.
'Error 1316 'Le compte spécifié existe déjà.
'Error 1317 'Le compte spécifié n’existe pas.
'Error 1318 'Le groupe spécifié existe déjà.
'Error 1319 'Le groupe spécifié n’existe pas.
'Error 1320 'Soit le compte d’utilisateur spécifié est déjà membre du groupe spécifié, soit il est impossible de supprimer le groupe spécifié car il contient un membre.
'Error 1321 'Le compte d’utilisateur spécifié n’est pas membre du groupe spécifié.
'Error 1322 'Cette opération n’est pas autorisée car elle pourrait entraîner la désactivation ou la suppression du compte d’administration, ou l’impossibilité de se connecter avec ce compte.
'Error 1323 'Impossible de mettre à jour le mot de passe. La valeur fournie en tant que mot de passe actuel est incorrecte.
'Error 1324 'Impossible de mettre à jour le mot de passe. Le nouveau mot de passe fourni contient des valeurs non permises dans les mots de passe.
'Error 1325 'Impossible de mettre à jour le mot de passe. Le nouveau mot de passe entré ne respecte pas les spécifications de longueur, de complexité ou d’historique du domaine.
'Error 1326 'Le nom d’utilisateur ou le mot de passe est incorrect.
'Error 1327 'Des restrictions de compte d’utilisateur empêchent cet utilisateur de se connecter. Des raisons possibles sont des mots de passe vides n’étant pas autorisés, des restrictions sur les heures de connexion ou une restriction de stratégie a été appliquée.
'Error 1328 'Votre compte comporte des restrictions des heures d’accès qui vous empêchent de vous connecter pour le moment.
'Error 1329 'Cet utilisateur n’est pas autorisé à se connecter sur cet ordinateur.
'Error 1330 'Le mot de passe de ce compte a expiré.
'Error 1331 'Cet utilisateur ne peut pas se connecter, car ce compte est actuellement désactivé.
'Error 1332 'Le mappage entre les noms de compte et les ID de sécurité n’a pas été effectué.
'Error 1333 'Trop d’identificateurs d’utilisateur local (LUID) ont été demandés en même temps.
'Error 1334 'Il n’y a plus d’identificateur d’utilisateur local (LUID) disponible.
'Error 1335 'La partie sous-autorité d’un ID de sécurité n’est pas valide pour cet usage particulier.
'Error 1336 'Structure de liste de contrôle de l’accès (ACL) non valide.
'Error 1337 'Structure d’ID de sécurité non valide.
'Error 1338 'Structure de descripteur de sécurité non valide.
'Error 1340 'Impossible de construire la liste de contrôle d’accès (ACL) ou la rubrique de contrôle d’accès (ACE) héritées.
'Error 1341 'Le serveur est actuellement désactivé.
'Error 1342 'Le serveur est actuellement activé.
'Error 1343 'La valeur fournie n’est pas valide pour une autorité d’identificateur.
'Error 1344 'Il n’y a plus de mémoire disponible pour les mises à jour des informations de sécurité.
'Error 1345 'Les attributs spécifiés ne sont pas valides ou sont incompatibles avec les attributs définis pour le groupe dans son ensemble.
'Error 1346 'Soit un niveau d’emprunt d’identité requis n’a pas été fourni, soit le niveau d’emprunt d’identité fourni n’est pas valide.
'Error 1347 'Impossible d’ouvrir un jeton de sécurité d’un niveau anonyme.
'Error 1348 'La catégorie d’informations de validation demandée n’est pas valide.
'Error 1349 'Le type du jeton est inadéquat pour ce genre d’utilisation.
'Error 1350 'Impossible d’accomplir une opération de sécurité sur un objet auquel aucune sécurité n’est associée.
'Error 1351 'Les informations de configuration n’ont pas pu être lues sur le contrôleur de domaine car l’ordinateur n’est pas disponible ou l’accès a été refusé.
'Error 1352 'Le serveur SAM (gestionnaire de comptes de sécurité) ou LSA (autorité de sécurité locale) n’était pas dans l’état approprié pour réaliser l’opération de sécurité.
'Error 1353 'Le domaine n’était pas dans l’état adéquat pour accomplir l’opération de sécurité.
'Error 1354 'Cette opération n’est permise que pour le contrôleur principal du domaine.
'Error 1355 'Le domaine spécifié n’existe pas ou n’a pas pu être contacté.
'Error 1356 'Le domaine spécifié existe déjà.
'Error 1357 'Tentative de dépassement du nombre maximal de domaines par serveur.
'Error 1358 'L’opération demandée est impossible en raison d’une défaillance irrémédiable du média ou de l’altération d’une structure de données sur le disque.
'Error 1359 'Une erreur interne s’est produite.
'Error 1360 'Des types d’accès génériques qui auraient déjà dû être mappés sur des types d’accès non génériques ont été rencontrés dans un masque d’accès.
'Error 1361 'Un descripteur de sécurité n’est pas au bon format (absolu ou auto-relatif).
'Error 1362 'Seuls les processus d’ouverture de session peuvent utiliser l’action demandée. Le processus appelant ne s’est pas inscrit en tant que processus d’ouverture de session.
'Error 1363 'Impossible d’ouvrir une nouvelle session avec un ID déjà utilisé.
'Error 1364 'Un package d’authentification spécifié est inconnu.
'Error 1365 'La session  ouverte n’est pas compatible avec l’opération demandée.
'Error 1366 'L’ID d’ouverture de session est déjà utilisé.
'Error 1367 'Une demande d’ouverture de session contient une valeur de type de connexion non valide.
'Error 1368 'Impossible d’emprunter une identité en utilisant un canal de communication nommé tant qu’aucune donnée n’a été lue dans ce canal.
'Error 1369 'L’état de transaction d’une sous-arborescence du Registre est incompatible avec l’opération demandée.
'Error 1370 'Une base de données de sécurité interne est endommagée.
'Error 1371 'Impossible d’accomplir cette action sur des comptes prédéfinis.
'Error 1372 'Impossible d’accomplir cette action sur ce groupe spécial prédéfini.
'Error 1373 'Impossible d’accomplir cette action sur cet utilisateur spécial prédéfini.
'Error 1374 'L’utilisateur ne peut pas être exclu du groupe car ce dernier est actuellement son groupe principal.
'Error 1375 'Le jeton est déjà utilisé en tant que jeton principal.
'Error 1376 'Le groupe local spécifié n’existe pas.
'Error 1377 'Le nom de compte spécifié n’est pas membre du groupe.
'Error 1378 'Le nom de compte spécifié est déjà membre du groupe.
'Error 1379 'Le groupe local spécifié existe déjà.
'Error 1380 'Échec d’ouverture de session  'l’utilisateur ne bénéficie pas du type d’ouverture de session demandé sur cet ordinateur.
'Error 1381 'Le nombre maximal de secrets pouvant être stockés sur un système donné a été dépassé.
'Error 1382 'La longueur d’un secret dépasse le maximum autorisé.
'Error 1383 'La base de données LSA (autorité de sécurité locale) présente une incohérence interne.
'Error 1384 'Lors d’une tentative d’ouverture de session, le contexte de sécurité de l’utilisateur a accumulé trop d’ID de sécurité.
'Error 1385 'Échec d’ouverture de session  'l’utilisateur ne bénéficie pas du type d’ouverture de session demandé sur cet ordinateur.
'Error 1386 'Un mot de passe à chiffrement croisé est nécessaire pour changer le mot de passe utilisateur.
'Error 1387 'Impossible d’ajouter ou de supprimer un membre du groupe local car ce membre n’existe pas.
'Error 1388 'Un nouveau membre ne peut être ajouté au groupe local car ce membre dispose d’un type de compte incorrect.
'Error 1389 'Trop d’ID de sécurité ont été spécifiés.
'Error 1390 'Un mot de passe à chiffrement croisé est nécessaire pour changer le mot de passe de cet utilisateur.
'Error 1391 'Indique qu’une ACL ne contient pas de composants héritables.
'Error 1392 'Le fichier ou le répertoire est endommagé et illisible.
'Error 1393 'La structure du disque est endommagée et illisible.
'Error 1394 'Il n’y a pas de clé de session utilisateur pour l’ouverture de session spécifiée.
'Error 1395 'Le service auquel vous accédez a une licence pour un nombre particulier de connexions. Il n’est plus possible d’établir des connexions au service pour le moment, car le nombre maximal de connexions autorisées est déjà atteint.
'Error 1396 'Le nom du compte cible est incorrect.
'Error 1397 'L’authentification mutuelle a échoué. Le mot de passe du serveur est obsolète sur le contrôleur de domaine.
'Error 1398 'L’heure et la date ne sont pas les mêmes entre le client et le serveur.
'Error 1399 'Cette opération ne peut pas être effectuée sur le domaine actuel.
'Error 1400 'Handle de fenêtre non valide.
'Error 1401 'Descripteur de menu non valide.
'Error 1402 'Descripteur de curseur non valide.
'Error 1403 'Descripteur de table d’accélérateurs non valide.
'Error 1404 'Descripteur de hook non valide.
'Error 1405 'Descripteur vers une structure de fenêtres multiples non valide.
'Error 1406 'Impossible de créer une fenêtre enfant supérieure.
'Error 1407 'Classe de fenêtre introuvable.
'Error 1408 'Fenêtre non valide, faisant partie d’un autre thread.
'Error 1409 'La touche d’accès rapide est déjà inscrite.
'Error 1410 'La classe existe déjà.
'Error 1411 'La classe n’existe pas.
'Error 1412 'Il reste des fenêtres ouvertes dans cette classe.
'Error 1413 'Index non valide.
'Error 1414 'Descripteur d’icône non valide.
'Error 1415 'Utilisation de mots de fenêtre de dialogue privés.
'Error 1416 'Identificateur de zone de liste introuvable.
'Error 1417 'Pas de caractères génériques.
'Error 1418 'Le thread n’a pas de Presse-papiers ouvert.
'Error 1419 'La touche d’accès rapide n’est pas inscrite.
'Error 1420 'La fenêtre n’est pas une fenêtre de dialogue valide.
'Error 1421 'ID de contrôle introuvable.
'Error 1422 'Message non valide pour une liste modifiable car elle est dépourvue de contrôle d’édition.
'Error 1423 'La fenêtre n’est pas une liste modifiable.
'Error 1424 'La hauteur ne doit pas dépasser 256.
'Error 1425 'Descripteur de contexte de périphérique (hDC) non valide.
'Error 1426 'Type de procédure de hook non valide.
'Error 1427 'Procédure de hook non valide.
'Error 1428 'Impossible d’établir un hook non local sans un descripteur de module.
'Error 1429 'Cette procédure de hook ne peut être définie que globalement.
'Error 1430 'La procédure de hook journal est déjà installée.
'Error 1431 'La procédure de hook n’est pas installée.
'Error 1432 'Message non valide pour une zone de liste à une seule sélection.
'Error 1433 'LB_SETCOUNT envoyé à une zone de liste active.
'Error 1434 'Cette zone de liste n’autorise pas les arrêts de tabulation.
'Error 1435 'Impossible de détruire un objet créé par un autre thread.
'Error 1436 'Les fenêtres enfants ne peuvent pas avoir de menus.
'Error 1437 'La fenêtre n’a pas de menu système.
'Error 1438 'Style de boîte de message non valide.
'Error 1439 'Paramètre à portée système (SPI_*) non valide.
'Error 1440 'Écran déjà verrouillé.
'Error 1441 'Tous les descripteurs de fenêtres dans une structure de fenêtres multiples doivent avoir le même parent.
'Error 1442 'La fenêtre n’est pas une fenêtre enfant.
'Error 1443 'Commande GW_* non valide.
'Error 1444 'Identificateur de thread non valide.
'Error 1445 'Impossible de traiter un message d’une fenêtre qui n’est pas une fenêtre MDI (multiple document interface).
'Error 1446 'Menu contextuel déjà actif.
'Error 1447 'La fenêtre ne comporte pas de barres de défilement.
'Error 1448 'L’intervalle de barre de défilement ne peut pas dépasser MAXLONG.
'Error 1449 'Impossible d’afficher ou de supprimer la fenêtre de la manière spécifiée.
'Error 1450 'Ressources système insuffisantes pour terminer le service demandé.
'Error 1451 'Ressources système insuffisantes pour terminer le service demandé.
'Error 1452 'Ressources système insuffisantes pour terminer le service demandé.
'Error 1453 'Quota insuffisant pour terminer le service demandé.
'Error 1454 'Quota insuffisant pour terminer le service demandé.
'Error 1455 'Le fichier de pagination est insuffisant pour terminer cette opération.
'Error 1456 'Pas d’élément de menu trouvé.
'Error 1457 'Descripteur de disposition de clavier non valide.
'Error 1458 'Type de crochet non autorisé.
'Error 1459 'Cette opération nécessite une station Windows interactive.
'Error 1460 'Cette opération s’est terminée car le délai d’attente a expiré.
'Error 1461 'Descripteur d’écran non valide.
'Error 1462 'Argument de taille incorrecte.
'Error 1463 'Le lien symbolique ne peut pas être suivi car son type est désactivé.
'Error 1464 'Cette application ne prend pas en charge l’opération actuelle sur les liens symboliques.
'Error 1465 'Windows n’a pas pu analyser les données XML demandées.
'Error 1466 'Une erreur s’est produite lors du traitement d’une signature numérique XML.
'Error 1467 'Cette application doit être redémarrée.
'Error 1468 'L’appelant a effectué une demande de connexion dans le compartiment de routage incorrect.
'Error 1469 'Une erreur AuthIP s’est produite lors de la tentative de connexion à l’hôte distant.
'Error 1470 'Ressources NVRAM insuffisantes pour terminer le service demandé. Un redémarrage peut s’avérer nécessaire.
'Error 1471 'Impossible de terminer l’opération demandée, car le processus spécifié n’est pas un processus d’interface graphique utilisateur.
'Error 1500 'Le fichier journal d’événements est endommagé.
'Error 1501 'Le fichier journal d’événements n’ayant pu être ouvert, le service d’enregistrement des événements n’a pas démarré.
'Error 1502 'Le fichier journal d’événements est plein.
'Error 1503 'Le fichier journal d’événements a changé entre les opérations de lecture.
'Error 1504 'Le travail spécifié possède déjà un conteneur qui lui est assigné.
'Error 1505 'Le travail spécifié ne possède pas de conteneur qui lui est assigné.
'Error 1550 'Le nom de tâche spécifié n’est pas valide.
'Error 1551 'L’index de tâche spécifié n’est pas valide.
'Error 1552 'Le thread spécifié joint déjà une tâche.
'Error 1601 'Impossible d’accéder au service Windows Installer. Ceci peut se produire si le programme d’installation de Windows n’est pas bien installé. Contactez votre support technique pour assistance.
'Error 1602 'L’utilisateur a annulé l’installation.
'Error 1603 'Erreur irrécupérable lors de l’installation.
'Error 1604 'Installation en suspense et non terminée.
'Error 1605 'Cette action n’est valide que pour les produits actuellement installés.
'Error 1606 'L’identificateur de fonctionnalité n’est pas inscrit.
'Error 1607 'L’identificateur de composant n’est pas inscrit.
'Error 1608 'Propriété inconnue.
'Error 1609 'Le descripteur est dans un état non valide.
'Error 1610 'Les données de configuration de ce produit sont endommagées. Contactez votre support technique.
'Error 1611 'Qualificatif de composant absent.
'Error 1612 'La source d’installation pour ce produit n’est pas disponible. Vérifiez que la source existe et que vous y avez accès.
'Error 1613 'Le package d’installation ne peut pas être installé par le service Windows Installer. Vous devez installer un Service Pack qui contient une version plus récente du service Windows Installer.
'Error 1614 'Le produit est désinstallé.
'Error 1615 'Syntaxe de requête SQL non valide ou non prise en charge.
'Error 1616 'Le champ de l’enregistrement n’existe pas.
'Error 1617 'Le périphérique a été supprimé.
'Error 1618 'Une autre installation est en cours d’exécution. Terminez celle-ci avant d’effectuer cette installation.
'Error 1619 'Impossible d’ouvrir le package d’installation. Vérifiez que le package existe et que vous y avez accès, ou contactez le revendeur de l’application pour vérifier que c’est un package Windows Installer valide.
'Error 1620 'Impossible d’ouvrir le package d’installation. Contactez le revendeur de l’application pour vérifier que c’est un package Windows Installer valide.
'Error 1621 'Une erreur est survenue lors du démarrage de l’interface utilisateur du service Windows Installer. Contactez votre support technique.
'Error 1622 'Erreur lors de l’ouverture du fichier journal d’installation. Vérifiez que l’emplacement du fichier journal spécifié existe et qu’il est accessible en écriture.
'Error 1623 'La langue de ce package d’installation n’est pas prise en charge par le système.
'Error 1624 'Erreur d’application des transformations. Vérifiez que les chemins de transformation spécifiés sont valides.
'Error 1625 'L’installation est interdite par la stratégie système. Contactez votre administrateur système.
'Error 1626 'Impossible d’exécuter la fonction.
'Error 1627 'La fonction a échoué lors de l’exécution.
'Error 1628 'La table spécifiée n’est pas valide ou est inconnue.
'Error 1629 'Les données fournies ont un type erroné.
'Error 1630 'Les données de ce type ne sont pas prises en charge.
'Error 1631 'Le service Windows Installer n’a pas pu démarrer. Contactez votre support technique.
'Error 1632 'Le lecteur contenant le répertoire temporaire est plein ou inaccessible. Libérez de l’espace sur le lecteur ou vérifiez que vous disposez  d’une autorisation d’accès en écriture sur le répertoire temporaire.
'Error 1633 'Ce package d’installation n’est pas pris en charge par ce type de processeur. Contactez le revendeur de votre produit.
'Error 1634 'Composant non utilisé sur cet ordinateur.
'Error 1635 'Impossible d’ouvrir ce package de mise à jour. Vérifiez que le package existe et que vous pouvez y accéder, ou contactez le revendeur de l’application afin de vérifier qu’il s’agit d’un package de mise à jour Windows Installer valide.
'Error 1636 'Impossible d’ouvrir ce package de mise à jour. Contactez le revendeur de l’application afin de vérifier qu’il s’agit d’un package de mise à jour Windows Installer valide.
'Error 1637 'Ce package de mise à jour n’est pas exécutable par le service Windows Installer. Vous devez installer un Service Pack qui contient une version du service Windows Installer plus récente.
'Error 1638 'Une autre version de ce produit est déjà installée. L’installation de cette version ne peut pas continuer. Pour configurer ou supprimer la version existante de ce produit utilisez Ajout/Suppression de programmes depuis le Panneau de configuration.
'Error 1639 'Argument de la ligne de commande non valide. Consultez le Kit de développement Windows Installer pour une aide détaillée de la ligne de commande.
'Error 1640 'Seuls les administrateurs ont le droit d’ajouter, supprimer, ou configurer un logiciel sur le serveur pendant une session à distance Terminal Server. Si vous voulez installer ou configurer un logiciel sur le serveur, contactez votre administrateur réseau.
'Error 1641 'L’opération demandée s’est terminée avec succès. L’ordinateur va être redémarré pour prendre en compte les changements.
'Error 1642 'La mise à niveau ne peut pas être installée par le service Windows Installer car le programme à mettre à niveau est absent, ou la mise à niveau est prévue pour une version du programme différente. Vérifiez que le programme à mettre à niveau existe sur votre or
'Error 1643 'Le package de mise à jour n’est pas autorisé par la stratégie de restriction logicielle.
'Error 1644 'Une ou plusieurs personnalisations ne sont pas autorisées par la stratégie de restriction logicielle.
'Error 1645 'L’installateur Windows ne permet pas l’installation à partir d’une connexion Bureau à distance.
'Error 1646 'La désinstallation du package de mise à jour n’est pas prise en charge.
'Error 1647 'La mise à jour ne s’applique pas à ce produit.
'Error 1648 'Aucune séquence valide n’a été trouvée pour l’ensemble des mises à jour.
'Error 1649 'La suppression de la mise à jour a été interdite par la stratégie.
'Error 1650 'Les données XML de la mise à jour ne sont pas valides.
'Error 1651 'Windows Installer n’autorise pas la mise à jour des produits publiés. Vous devez ajouter au moins une fonctionnalité du produit avant d’appliquer la mise à jour.
'Error 1652 'Le service Windows Installer n’est pas accessible en mode sans échec. Réessayez si votre ordinateur n’est pas en mode sans échec ou utilisez la restauration du système pour restaurer votre ordinateur dans un état précédent correct.
'Error 1653 'Une exception FailFast s’est produite. Les gestionnaires d’exceptions ne seront pas appelés et le processus va se terminer immédiatement.
'Error 1654 'L’application que vous tentez d’exécuter n’est pas prise en charge sur cette version de Windows.
'Error 1655 'L’opération a été bloquée, car le processus interdit la génération de code dynamique.
'Error 1656 'Les objets ne sont pas identiques.
'Error 1657 'Le chargement du fichier image spécifié a été bloqué, car il n’active pas une fonction requise par le processus  'protection du flux de contrôle.
'Error 1660 'Le contexte de thread n’a pas pu être mis à jour, car cette opération a été limitée pour le processus.
'Error 1661 'Une opération d’accès non valide a été tentée sur une section/un fichier privé avec plusieurs partitions.
'Error 1700 'Liaison de chaîne non valide.
'Error 1701 'Le handle de liaison est d’un type incorrect.
'Error 1702 'Handle de liaison non valide.
'Error 1703 'La séquence de protocole RPC n’est pas prise en charge.
'Error 1704 'La séquence de protocole RPC n’est pas valide.
'Error 1705 'L’identificateur unique universel (UUID) de la chaîne n’est pas valide.
'Error 1706 'Format de point final non valide.
'Error 1707 'Adresse réseau non valide.
'Error 1708 'Point final introuvable.
'Error 1709 'Valeur de temporisation non valide.
'Error 1710 'Identificateur unique universel de l’objet (UUID) introuvable.
'Error 1711 'L’identificateur unique universel de l’objet (UUID) a déjà été inscrit.
'Error 1712 'L’identificateur unique universel du type (UUID) a déjà été inscrit.
'Error 1713 'Le serveur RPC est déjà à l’écoute.
'Error 1714 'Aucune séquence de protocole n’a été inscrite.
'Error 1715 'Le serveur RPC n’est pas à l’écoute.
'Error 1716 'Type de gestionnaire inconnu.
'Error 1717 'Interface inconnue.
'Error 1718 'Aucune liaison n’existe.
'Error 1719 'Il n’y a pas de séquence de protocole.
'Error 1720 'Impossible de créer le point final.
'Error 1721 'Ressources insuffisantes pour accomplir cette opération.
'Error 1722 'Le serveur RPC n’est pas disponible.
'Error 1723 'Le serveur RPC est trop occupé pour terminer cette opération.
'Error 1724 'Options réseau non valides.
'Error 1725 'Il n’y a pas d’appel de procédure distant actif dans ce thread.
'Error 1726 'Échec de l’appel de procédure distante.
'Error 1727 'L’appel de procédure distante a échoué et ne s’est pas exécuté.
'Error 1728 'Une erreur de protocole RPC s’est produite.
'Error 1729 'L’accès au proxy HTTP est refusé.
'Error 1730 'La syntaxe de transfert n’est pas prise en charge par le serveur RPC.
'Error 1732 'Le type de l’identificateur unique universel (UUID) n’est pas reconnu.
'Error 1733 'Nom symbolique non valide.
'Error 1734 'Limites de tableau non valides.
'Error 1735 'La liaison ne contient pas de nom de rubrique.
'Error 1736 'Syntaxe de nom non valide.
'Error 1737 'La syntaxe de nom n’est pas prise en charge.
'Error 1739 'Aucune adresse réseau n’est disponible pour construire un identificateur unique universel (UUID).
'Error 1740 'Le point final est un doublon.
'Error 1741 'Type d’authentification inconnu.
'Error 1742 'Le nombre maximal d’appels est insuffisant.
'Error 1743 'Chaîne trop longue.
'Error 1744 'Séquence de protocole RPC introuvable.
'Error 1745 'Numéro de procédure hors de l’intervalle admis.
'Error 1746 'La liaison ne contient pas d’informations d’authentification.
'Error 1747 'Service d’authentification inconnu.
'Error 1748 'Niveau d’authentification inconnu.
'Error 1749 'Contexte de sécurité non valide.
'Error 1750 'Service d’autorisation inconnu.
'Error 1751 'Rubrique non valide.
'Error 1752 'Le point final de serveur ne peut pas accomplir l’opération.
'Error 1753 'Le mappeur de point final n’a plus de point final disponible.
'Error 1754 'Aucune interface n’a été exportée.
'Error 1755 'Nom de rubrique incomplet.
'Error 1756 'Option de version non valide.
'Error 1757 'Il n’y a plus de membre.
'Error 1758 'Il n’y a aucune exportation à annuler.
'Error 1759 'L’interface n’a pas été trouvée.
'Error 1760 'La rubrique existe déjà.
'Error 1761 'Rubrique introuvable.
'Error 1762 'Le service de noms n’est pas disponible.
'Error 1763 'La famille d’adresses réseau n’est pas valide.
'Error 1764 'L’opération demandée n’est pas prise en charge.
'Error 1765 'Il n’y a aucun contexte de sécurité disponible pour autoriser l’emprunt d’identité.
'Error 1766 'Une erreur interne s’est produite lors d’un appel de procédure distante (RPC).
'Error 1767 'Le serveur RPC a tenté une division d’un entier par zéro.
'Error 1768 'Erreur d’adressage sur le serveur RPC.
'Error 1769 'Une opération en virgule flottante effectuée par le serveur RPC a causé une division par zéro.
'Error 1770 'Une opération en virgule flottante effectuée par le serveur RPC a causé un dépassement négatif.
'Error 1771 'Une opération en virgule flottante effectuée par le serveur RPC a causé un dépassement de capacité.
'Error 1772 'La liste des serveurs RPC disponibles pour la liaison des auto-descripteurs est épuisée.
'Error 1773 'Impossible d’ouvrir le fichier de la table de traduction des caractères.
'Error 1774 'Le fichier contenant la table de traduction de caractères contient moins de 512 octets.
'Error 1775 'Un descripteur de contexte null a été passé du client à l’hôte lors d’un appel de procédure distante (RPC).
'Error 1777 'Le descripteur de contexte a changé lors d’un appel de procédure distante (RPC).
'Error 1778 'Les handles de liaison passés à un appel de procédure distante ne correspondent pas.
'Error 1779 'Le stub ne parvient pas à obtenir le descripteur d’appel de procédure distante (RPC).
'Error 1780 'Un pointeur de référence nul a été passé au stub.
'Error 1781 'Valeur d’énumération hors de l’intervalle admis.
'Error 1782 'Le nombre d’octets est insuffisant.
'Error 1783 'Le relais a reçu des données incorrectes.
'Error 1784 'Le tampon utilisateur fourni n’est pas valide pour l’opération demandée.
'Error 1785 'Le média disque n’est pas reconnu. Il n’est peut-être pas formaté.
'Error 1786 'La station de travail n’a pas de secret d’approbation.
'Error 1787 'La base de données de sécurité du serveur n’a pas de compte d’ordinateur pour la relation d’approbation avec cette station de travail.
'Error 1788 'La relation d’approbation entre le domaine principal et le domaine approuvé a échoué.
'Error 1789 'La relation d’approbation entre cette station de travail et le domaine principal a échoué.
'Error 1790 'Échec d’ouverture de session sur le réseau.
'Error 1791 'Un appel de procédure distant est déjà en cours pour ce thread.
'Error 1792 'Une tentative d’ouverture de session a eu lieu alors que le service d’ouverture de session réseau n’avait pas démarré.
'Error 1793 'Le compte de l’utilisateur a expiré.
'Error 1794 'Le redirecteur est en cours d’utilisation et ne peut pas être déchargé.
'Error 1795 'Le pilote d’imprimante spécifié est déjà installé.
'Error 1796 'Le port spécifié est inconnu.
'Error 1797 'Pilote d’imprimante inconnu.
'Error 1798 'Processeur d’impression inconnu.
'Error 1799 'Le fichier séparateur spécifié n’est pas valide.
'Error 1800 'La priorité spécifiée n’est pas valide.
'Error 1801 'Le nom de l’imprimante n’est pas valide.
'Error 1802 'L’imprimante existe déjà.
'Error 1803 'Commande d’imprimante non valide.
'Error 1804 'Le type de donnée spécifié n’est pas valide.
'Error 1805 'L’environnement spécifié n’est pas valide.
'Error 1806 'Il n’y a plus de liaison.
'Error 1807 'Le compte utilisé est un compte d’approbation inter-domaines. Utilisez votre compte d’utilisateur global ou local pour accéder à ce serveur.
'Error 1808 'Le compte utilisé est un compte d’ordinateur. Utilisez votre compte d’utilisateur global ou local pour accéder à ce serveur.
'Error 1809 'Le compte utilisé est un compte d’approbation de serveur. Utilisez votre compte d’utilisateur global ou local pour accéder à ce serveur.
'Error 1810 'Le nom ou l’ID de sécurité (SID) du domaine spécifié n’est pas cohérent avec les informations d’approbation pour ce domaine.
'Error 1811 'Le serveur est en cours d’utilisation et ne peut pas être déchargé.
'Error 1812 'Le fichier image spécifié ne contenait pas de section ressource.
'Error 1813 'Le type de ressource spécifié ne peut être trouvé dans le fichier image.
'Error 1814 'Le nom de ressource spécifié ne peut être trouvé dans le fichier image.
'Error 1815 'L’ID de langue de ressource spécifié ne peut être trouvé dans le fichier image.
'Error 1816 'Le quota disponible est insuffisant pour traiter cette commande.
'Error 1817 'Aucune interface n’a été inscrite.
'Error 1818 'L’appel de procédure distante a été annulé.
'Error 1819 'Le handle de liaison ne contient pas toutes les informations nécessaires.
'Error 1820 'Échec de la communication lors de l’appel d’une procédure distante.
'Error 1821 'Le niveau d’authentification demandé n’est pas pris en charge.
'Error 1822 'Aucun nom principal déclaré.
'Error 1823 'L’erreur spécifiée n’est pas un code d’erreur Windows RPC correct.
'Error 1824 'Un identificateur UUID qui n’est valide que sur cet ordinateur a été alloué.
'Error 1825 'Une erreur spécifique du package de sécurité s’est produite.
'Error 1826 'Thread non annulé.
'Error 1827 'Opération non valide sur le handle de codage/décodage.
'Error 1828 'Version incompatible du package de sérialisation.
'Error 1829 'Version incompatible de la carte RPC.
'Error 1830 'L’objet canal RPC n’est pas valide ou est endommagé.
'Error 1831 'Une opération non valide a été tentée sur un objet canal RPC donné.
'Error 1832 'La version du canal RPC n’est pas prise en charge.
'Error 1833 'Le serveur proxy HTTP a refusé la connexion, car l’authentification du cookie a échoué.
'Error 1834 'Le serveur RPC est suspendu et n'a pas pu être relancé pour cette demande. L'appel n'a pas été exécuté.
'Error 1835 'L’appel RPC contient un trop grand nombre de handles à transmettre dans une même demande.
'Error 1836 'L’appel RPC contient un handle qui diffère du type de handle déclaré.
'Error 1898 'Le membre de groupe n’a pas été trouvé.
'Error 1899 'Impossible de créer l’entrée de la base de données du mappeur de point final.
'Error 1900 'L’identificateur unique universel de l’objet (UUID) est l’UUID nul.
'Error 1901 'L’heure spécifiée n’est pas valide.
'Error 1902 'Le nom de formulaire spécifié n’est pas valide.
'Error 1903 'La taille de formulaire spécifiée n’est pas valide.
'Error 1904 'Quelqu’un est déjà en attente sur le descripteur d’imprimante spécifié.
'Error 1905 'L’imprimante spécifiée a été supprimée.
'Error 1906 'L’état de l’imprimante n’est pas valide.
'Error 1907 'Le mot de passe de l’utilisateur doit être modifié avant la première connexion.
'Error 1908 'Impossible de trouver un contrôleur de domaine pour ce domaine.
'Error 1909 'Le compte référencé est actuellement verrouillé et il se peut qu’il ne soit pas possible de s’y connecter.
'Error 1910 'L’exportateur d’objet spécifié est introuvable.
'Error 1911 'L’objet spécifié est introuvable.
'Error 1912 'Le solveur d’objet spécifié est introuvable.
'Error 1913 'Il reste des données à envoyer dans la zone de mémoire tampon de demande.
'Error 1914 'Handle d’appel de procédure distante asynchrone non valide.
'Error 1915 'Handle d’appel RPC asynchrone non valide pour cette opération.
'Error 1916 'L’objet Canal RPC a déjà été refermé.
'Error 1917 'L’appel RPC s’est terminé avant que les canaux soient traités.
'Error 1918 'Plus aucune donnée disponible dans le canal RPC.
'Error 1919 'Aucun nom de site n’est disponible pour cet ordinateur.
'Error 1920 'Le système ne peut pas accéder au fichier.
'Error 1921 'Le nom du fichier ne peut pas être résolu par le système.
'Error 1922 'Le type d’entrée est incorrect.
'Error 1923 'Impossible d’exporter tous les objets UUID vers l’entrée spécifiée.
'Error 1924 'Impossible d’exporter l’interface vers l’entrée spécifiée.
'Error 1925 'Impossible d’ajouter le profile spécifié.
'Error 1926 'Impossible d’ajouter l’élément de profile spécifié.
'Error 1927 'Impossible de supprimer l’élément de profile spécifié.
'Error 1928 'Impossible d’ajouter l’élément de groupe.
'Error 1929 'Impossible de supprimer l’élément de groupe.
'Error 1930 'Le pilote d’imprimante n’est pas compatible avec une stratégie activée sur votre ordinateur qui bloque les pilotes NT 4.0.
'Error 1931 'Le contexte a expiré et ne peut plus être utilisé.
'Error 1932 'Le quota de création d’approbation déléguée de l’utilisateur actuel a dépassé sa valeur autorisée.
'Error 1933 'Le quota de création d’approbation déléguée a dépassé sa valeur autorisée.
'Error 1934 'Le quota de suppression d’approbation déléguée de l’utilisateur actuel a dépassé sa valeur autorisée.
'Error 1935 'L’ordinateur sur lequel vous êtes connecté est protégé par un pare-feu d’authentification. Le compte spécifié n’est pas autorisé à s’authentifier sur l’ordinateur.
'Error 1936 'Les connexions distantes au spouleur d’impression sont bloquées par un jeu de stratégie sur votre ordinateur.
'Error 1937 'L’authentification a échoué, car l’authentification NTLM est désactivée.
'Error 1938 'Échec d’ouverture de session  'la stratégie EAS nécessite que l’utilisateur modifie son mot de passe avant d’effectuer cette opération.
'Error 1939 'Un administrateur a limité les connexions. Pour vous connecter, vérifiez que votre appareil est raccordé à Internet, puis demandez à votre administrateur de se connecter en premier.
'Error 2000 'Le format pixel n’est pas valide.
'Error 2001 'Le pilote spécifié n’est pas valide.
'Error 2002 'Le style de la fenêtre ou l’attribut de la classe n’est pas valide pour cette opération.
'Error 2003 'L’opération de métafichier demandée n’est pas prise en charge.
'Error 2004 'L’opération de transformation demandée n’est pas prise en charge.
'Error 2005 'L’opération d’écrêtage demandée n’est pas prise en charge.
'Error 2010 'Le module de gestion de couleurs spécifié n’est pas valide.
'Error 2011 'Le profil de couleurs spécifié n’est pas valide.
'Error 2012 'La balise spécifiée n’a pas été trouvée.
'Error 2013 'Une balise requise n’est pas présente.
'Error 2014 'La balise spécifiée est déjà présente.
'Error 2015 'Le profil de couleurs spécifié n’est pas associé au périphérique spécifié.
'Error 2016 'Le profil de couleurs spécifié n’a pas été trouvé.
'Error 2017 'L’espace de couleurs spécifié n’est pas valide.
'Error 2018 'La gestion des couleurs ICM n’est pas activée.
'Error 2019 'Une erreur s’est produite lors de la suppression de la transformation de couleurs.
'Error 2020 'La transformation de couleurs spécifiée n’est pas valide.
'Error 2021 'La transformation spécifiée ne correspond pas à l’espace de couleurs de la bitmap.
'Error 2022 'Le numéro de couleur nommée spécifié n’est pas présent dans le profil.
'Error 2023 'Le profil spécifié est destiné à un périphérique dont le type est différent de celui du périphérique spécifié.
'Error 2102 'Le pilote de station de travail n’est pas installé.
'Error 2103 'Le serveur est introuvable.
'Error 2104 'Une erreur interne s’est produite. Le réseau ne peut pas accéder à un segment de mémoire partagée.
'Error 2105 'Une insuffisance de ressources réseau s’est produite.
'Error 2106 'Cette opération n’est pas autorisée sur les stations de travail.
'Error 2107 'Le périphérique n’est pas connecté.
'Error 2108 'La connexion réseau s’est bien passée, mais la saisie d’un mot de passe autre que celui spécifié à l’origine a été demandée à l’utilisateur.
'Error 2109 'La connexion réseau a été effectuée correctement en utilisant les informations d’identification par défaut.
'Error 2114 'Le service Serveur n’a pas démarré.
'Error 2115 'La file d’attente est vide.
'Error 2116 'Le périphérique ou le répertoire n’existe pas.
'Error 2117 'L’opération n’est pas valide sur une ressource redirigée.
'Error 2118 'Ce nom de partage existe déjà.
'Error 2119 'La ressource demandée est actuellement épuisée sur le serveur.
'Error 2121 'L’ajout d’éléments demandé fait dépasser le maximum autorisé.
'Error 2122 'Le service homologue n’accepte que deux utilisateurs simultanément.
'Error 2123 'La zone tampon de retour API est insuffisante.
'Error 2127 'Une erreur d’API distante s’est produite.
'Error 2131 'Le système a rencontré une erreur lors de l’ouverture ou de la lecture du fichier de configuration.
'Error 2136 'Une erreur réseau générale s’est produite.
'Error 2137 'Le service Station de travail se trouve dans un état instable. Redémarrez l’ordinateur avant de redémarrer le service Station de travail.
'Error 2138 'Le service Station de travail n’a pas été mis en route.
'Error 2139 'L’information demandée n’est pas disponible.
'Error 2140 'Une erreur Windows interne s’est produite.
'Error 2141 'Le serveur n’est pas configuré pour les transactions.
'Error 2142 'L’API demandée n’est pas prise en charge sur le serveur distant.
'Error 2143 'Le nom d’événement est incorrect.
'Error 2144 'Le nom d’ordinateur existe déjà sur le réseau. Modifiez-le et redémarrez l’ordinateur.
'Error 2146 'Le composant spécifié est introuvable dans les informations de configuration.
'Error 2147 'Le paramètre spécifié est introuvable dans les informations de configuration.
'Error 2149 'Une ligne du fichier de configuration est trop longue.
'Error 2150 'L’imprimante n’existe pas.
'Error 2151 'Le travail d’impression n’existe pas.
'Error 2152 'Impossible de trouver la destination d’impression.
'Error 2153 'La destination d’impression existe déjà.
'Error 2154 'La file d’attente d’impression existe déjà.
'Error 2155 'Impossible d’ajouter d’autres imprimantes.
'Error 2156 'Impossible d’ajouter d’autres travaux d’impression.
'Error 2157 'Impossible d’ajouter d’autres destinations d’impression.
'Error 2158 'Cette destination d’impression est inactive et ne peut pas accepter d’opérations de service.
'Error 2159 'Cette demande de destination d’impression contient une opération de service non valide.
'Error 2160 'Le processeur d’impression ne répond pas.
'Error 2161 'Le spouleur n’est pas en cours d’exécution.
'Error 2162 'Impossible d’accomplir cette opération sur la destination d’impression dans son état actuel.
'Error 2163 'Impossible d’accomplir cette opération sur la file d’attente d’impression dans son état actuel.
'Error 2164 'Impossible d’accomplir cette opération sur le travail d’impression dans son état actuel.
'Error 2165 'Une erreur s’est produite lors de l’allocation de mémoire au spouleur.
'Error 2166 'Le pilote de périphérique n’existe pas.
'Error 2167 'Le type de données n’est pas pris en charge par le processeur.
'Error 2168 'Le processeur d’impression n’est pas installé.
'Error 2180 'La base de données des services est verrouillée.
'Error 2181 'La table de services est saturée.
'Error 2182 'Le service demandé a déjà été démarré.
'Error 2183 'Le service ne répond pas aux actions de contrôle.
'Error 2184 'Le service n’a pas été démarré.
'Error 2185 'Le nom de service n’est pas valide.
'Error 2186 'Le service ne répond pas à la fonction de maintenance.
'Error 2187 'La commande du service est occupée.
'Error 2188 'Le fichier de configuration contient un nom de programme de service non valide.
'Error 2189 'Dans son état actuel, le service ne répond pas aux commandes.
'Error 2190 'Le service s’est arrêté de manière anormale.
'Error 2191 'La demande de pause, de reprise ou d’arrêt n’est pas valide pour ce service.
'Error 2192 'Le nom de service est introuvable dans la table du répartiteur de commandes de service.
'Error 2193 'Échec de la lecture de canal de communication par le répartiteur de commandes de service.
'Error 2194 'Impossible de créer un thread pour le nouveau service.
'Error 2200 'Cette station de travail est déjà connectée au réseau.
'Error 2201 'Cette station de travail n’est pas encore connectée au réseau.
'Error 2202 'Le nom d’utilisateur spécifié n’est pas valide.
'Error 2203 'Le paramètre de mot de passe n’est pas valide.
'Error 2204 'Le processeur d’accès n’a pas ajouté l’alias pour les messages.
'Error 2205 'Le processeur d’accès n’a pas ajouté l’alias pour les messages.
'Error 2206 'Le processeur de déconnexion n’a pas supprimé l’alias pour les messages.
'Error 2207 'Le processeur de déconnexion n’a pas supprimé l’alias pour les messages.
'Error 2209 'Les accès au réseau sont suspendus.
'Error 2210 'Un conflit d’accès centralisé a eu lieu sur un serveur.
'Error 2211 'Le serveur est configuré sans chemin utilisateur valide.
'Error 2212 'Une erreur s’est produite lors du chargement ou de l’exécution du script d’ouverture de session.
'Error 2214 'Le serveur d’accès n’ayant pas été spécifié, une ouverture de session autonome sera réalisée.
'Error 2215 'Le serveur d’accès est introuvable.
'Error 2216 'Il y a déjà un domaine d’accès pour cet ordinateur.
'Error 2217 'Le serveur d’accès n’a pas pu valider l’accès.
'Error 2219 'La base de données de la sécurité est introuvable.
'Error 2220 'Le nom de groupe est introuvable.
'Error 2221 'Le nom d’utilisateur est introuvable.
'Error 2222 'Le nom de ressource est introuvable.
'Error 2223 'Le groupe existe déjà.
'Error 2224 'Le compte existe déjà.
'Error 2225 'La liste d’autorisations pour cette ressource existe déjà.
'Error 2226 'Cette opération n’est autorisée que sur le contrôleur principal du domaine.
'Error 2227 'La base de données de la sécurité n’a pas été mise en route.
'Error 2228 'Il y a trop de noms dans la base de données des comptes d’utilisateurs.
'Error 2229 'Une erreur d’E/S disque s’est produite.
'Error 2230 'La limite de 64 rubriques par ressource a été dépassée.
'Error 2231 'Impossible de supprimer le compte d’un utilisateur conduisant une session.
'Error 2232 'Impossible d’accéder au répertoire parent.
'Error 2233 'Impossible d’agrandir le segment du cache de sessions de la base de données de la sécurité.
'Error 2234 'Cette opération n’est pas autorisée sur ce groupe spécial.
'Error 2235 'Cet utilisateur ne se trouve pas dans le cache de sessions de la base de données des comptes d’utilisateurs.
'Error 2236 'L’utilisateur fait déjà partie de ce groupe.
'Error 2237 'L’utilisateur ne fait pas partie de ce groupe.
'Error 2238 'Ce compte d’utilisateur n’est pas défini.
'Error 2239 'Ce compte d’utilisateur est expiré.
'Error 2240 'L’utilisateur n’est pas autorisé à ouvrir une session depuis cette station de travail.
'Error 2241 'L’utilisateur n’est pas autorisé à ouvrir une session maintenant.
'Error 2242 'Le mot de passe de cet utilisateur est expiré.
'Error 2243 'Le mot de passe de cet utilisateur ne peut pas changer.
'Error 2244 'Impossible d’employer ce mot de passe maintenant.
'Error 2245 'Ce mot de passe ne correspond pas aux critères de stratégie de mot de passe. Vérifiez la longueur de mot de passe minimale, la complexité du mot de passe et l’historique des critères de mots de passe.
'Error 2246 'Le mot de passe de cet utilisateur est trop récent pour être modifié.
'Error 2247 'La base de données de la sécurité est endommagée.
'Error 2248 'La mise à jour de cette copie de la base de données de la sécurité réseau/locale n’est pas nécessaire.
'Error 2249 'Cette base de données dupliquée n’étant pas à jour, une synchronisation est nécessaire.
'Error 2250 'Cette connexion réseau n’existe pas.
'Error 2251 'Ce type asg_type n’est pas valide.
'Error 2252 'Ce périphérique est déjà partagé.
'Error 2253 'Le nom de l’utilisateur ne peut pas être le même que celui de l’ordinateur.
'Error 2270 'Le nom d’ordinateur n’a pas pu être ajouté en tant qu’alias de message. Ce nom existe peut-être déjà sur le réseau.
'Error 2271 'Le service Affichage des messages a déjà été démarré.
'Error 2272 'Le service Affichage des messages n’a pas pu démarrer.
'Error 2273 'L’alias est introuvable sur le réseau.
'Error 2274 'Cet alias a déjà été transmis.
'Error 2275 'Cet alias a été ajouté, mais il est encore transmis.
'Error 2276 'Cet alias existe déjà localement.
'Error 2277 'Dépassement du nombre maximal d’alias.
'Error 2278 'Il est impossible de supprimer le nom d’ordinateur.
'Error 2279 'Impossible de transmettre des messages en sens inverse vers la même station de travail.
'Error 2280 'Une erreur s’est produite dans le processeur de messages du domaine.
'Error 2281 'Le message a été envoyé, mais le destinataire a suspendu le service Affichage des messages.
'Error 2282 'Le message a été envoyé, mais non reçu.
'Error 2283 'L’alias est actuellement utilisé. Réessayez ultérieurement.
'Error 2284 'Le service Affichage des messages n’a pas été démarré.
'Error 2285 'Le nom ne se trouve pas sur l’ordinateur local.
'Error 2286 'L’alias de messages transmis est introuvable sur le réseau.
'Error 2287 'La table des alias de la station de travail distante est saturée.
'Error 2288 'Les messages adressés à cet alias ne sont pas transmis actuellement.
'Error 2289 'Le message à diffusion générale a été tronqué.
'Error 2294 'Ce nom de périphérique n’est pas valide.
'Error 2295 'Erreur en écriture.
'Error 2297 'Il y a un alias en double sur le réseau.
'Error 2298 'Cet alias sera supprimé ultérieurement.
'Error 2299 'Cet alias n’a pas été supprimé dans tous les réseaux.
'Error 2300 'Cette opération n’est pas autorisée sur les ordinateurs connectés à plusieurs réseaux.
'Error 2310 'Cette ressource partagée n’existe pas.
'Error 2311 'Ce périphérique n’est pas partagé.
'Error 2312 'Il n’existe pas de session ouverte sous ce nom d’ordinateur.
'Error 2314 'Il n’existe pas de fichier ouvert portant ce numéro d’identification.
'Error 2315 'L’exécution d’une commande d’administration distante s’est avérée impossible.
'Error 2316 'L’ouverture d’un fichier temporaire distant s’est avérée impossible.
'Error 2317 'Les données fournies par une commande d’administration distante ont été tronquées pour ne pas dépasser 64 Ko.
'Error 2318 'Impossible de partager ce périphérique comme ressource étant à la fois mise en file d’attente et non mise en file d’attente.
'Error 2319 'Il est possible que le contenu de la liste de serveurs soit incorrect.
'Error 2320 'L’ordinateur n’est pas actif dans ce domaine.
'Error 2321 'Le partage doit être supprimé du Système de fichiers distribués (DFS) avant de pouvoir être supprimé.
'Error 2331 'L’opération n’est pas valide pour ce périphérique.
'Error 2332 'Impossible de partager ce périphérique.
'Error 2333 'Ce périphérique n’était pas ouvert.
'Error 2334 'Cette liste de noms de périphérique n’est pas valide.
'Error 2335 'La priorité de la file d’attente n’est pas valide.
'Error 2337 'Il n’y a pas de périphériques de communication partagés.
'Error 2338 'La file d’attente spécifiée n’existe pas.
'Error 2340 'Cette liste de périphériques n’est pas valide.
'Error 2341 'Le périphérique demandé n’est pas valide.
'Error 2342 'Ce périphérique est déjà utilisé par le spouleur.
'Error 2343 'Ce périphérique est déjà utilisé en tant que périphérique de communication.
'Error 2351 'Ce nom d’ordinateur n’est pas valide.
'Error 2354 'La chaîne et le préfixe spécifiés sont trop longs.
'Error 2356 'Ce composant de chemin n’est pas valide.
'Error 2357 'Il est impossible de déterminer le type de l’entrée.
'Error 2362 'La zone tampon des types n’est pas assez grande.
'Error 2370 'Les fichiers profils ne peuvent pas dépasser 64 Ko.
'Error 2371 'Le décalage de début est en dehors de l’intervalle admis.
'Error 2372 'Le système ne peut pas supprimer les connexions en cours aux ressources du réseau.
'Error 2373 'Le système n’a pas pu analyser la ligne de commande dans ce fichier.
'Error 2374 'Une erreur s’est produite lors du chargement du fichier profil.
'Error 2375 'Erreurs lors de la sauvegarde du fichier profil. Le profil a été partiellement sauvegardé.
'Error 2377 'Le fichier journal %1 est plein.
'Error 2378 'Ce fichier journal a changé entre des lectures.
'Error 2379 'Le fichier journal %1 est endommagé.
'Error 2380 'Le chemin source ne peut être un répertoire.
'Error 2381 'Le chemin source n’est pas autorisé.
'Error 2382 'Le chemin destination n’est pas autorisé.
'Error 2383 'Les chemins source et destination sont sur des serveurs différents.
'Error 2385 'Le serveur de Télétraitement demandé est suspendu.
'Error 2389 'Une erreur s’est produite lors de la communication avec un serveur de télétraitement.
'Error 2391 'Une erreur s’est produite lors du lancement d’un processus à l’arrière-plan.
'Error 2392 'La ressource partagée à laquelle vous êtes connecté est introuvable.
'Error 2400 'Le numéro de carte réseau n’est pas valide.
'Error 2401 'Cette connexion réseau comporte des fichiers ouverts ou des requêtes en attente.
'Error 2402 'Il existe encore des connexions actives.
'Error 2403 'Ce nom de partage ou ce mot de passe n’est pas valide.
'Error 2404 'Impossible de déconnecter le périphérique car il est utilisé par un processus actif.
'Error 2405 'La lettre de lecteur est utilisée localement.
'Error 2430 'Le client spécifié est déjà enregistré pour l’événement spécifié.
'Error 2431 'La table des alertes est saturée.
'Error 2432 'Un nom d’alerte non valide ou inexistant a été généré.
'Error 2433 'Le destinataire des alertes n’est pas valide.
'Error 2434 'La session d’un utilisateur sur ce serveur a été supprimée car ses heures d’accès autorisé ne sont plus valides.
'Error 2440 'Le fichier journal ne contient pas le numéro d’enregistrement demandé.
'Error 2450 'La base de données des comptes d’utilisateurs n’est pas configurée convenablement.
'Error 2451 'Cette opération est interdite durant l’exécution du service Accès réseau.
'Error 2452 'Cette opération est interdite sur le dernier compte administratif.
'Error 2453 'Le contrôleur de ce domaine est introuvable.
'Error 2454 'Il est impossible de définir les informations d’ouverture de session pour cet utilisateur.
'Error 2455 'Le service Accès réseau n’a pas été démarré.
'Error 2456 'Il est impossible d’agrandir la base de données des comptes d’utilisateurs.
'Error 2457 'L’horloge de ce serveur n’est pas synchronisée avec celle du contrôleur principal de domaine.
'Error 2458 'Un problème de mot de passe a été détecté.
'Error 2460 'L’identificateur de serveur spécifié n’est pas valide.
'Error 2461 'L’identificateur de session spécifié n’est pas valide.
'Error 2462 'L’identificateur de connexion spécifié n’est pas valide.
'Error 2463 'La table des serveurs disponibles est saturée.
'Error 2464 'Le serveur ne peut pas prendre en charge davantage de sessions.
'Error 2465 'Le serveur ne peut pas prendre en charge davantage de connexions.
'Error 2466 'Le serveur ne peut pas prendre en charge davantage de fichiers ouverts.
'Error 2467 'Aucun serveur secondaire n’est enregistré sur ce serveur.
'Error 2470 'Essayez plutôt une version bas niveau (protocole d’administration à distance) de l’API.
'Error 2480 'Le service Onduleur n’a pas pu accéder au pilote onduleur.
'Error 2481 'Le service Onduleur n’est pas configuré convenablement.
'Error 2482 'Le service Onduleur n’a pas pu accéder au port COM spécifié.
'Error 2483 'Le service Onduleur n’a pas démarré car l’alimentation de secours lui a signalé un problème de ligne ou de batterie faible.
'Error 2484 'Le service Onduleur n’a pas réussi à accomplir un arrêt ordonné du système.
'Error 2500 'Le programme ci-dessous a renvoyé un code d’erreur MS-DOS :
'Error 2501 'Le programme ci-dessous a besoin de plus de mémoire :
'Error 2502 'Le programme suivant a appelé une fonction MS-DOS non prise en charge :
'Error 2503 'L’amorçage de la station de travail a échoué.
'Error 2504 'Le fichier ci-dessous est endommagé.
'Error 2505 'Aucun chargeur n’est spécifié dans le fichier de définition du bloc d’amorçage.
'Error 2506 'NETBIOS a retourné une erreur  'NCB et SMB sont fournis ci-dessus.
'Error 2507 'Une erreur E/S disque s’est produite.
'Error 2508 'La substitution des paramètres d’image a échoué.
'Error 2509 'Trop de paramètres de l’image franchissent des limites de secteurs de disques.
'Error 2510 'L’image n’a pas été générée depuis une disquette MS-DOS formatée avec /S.
'Error 2511 'Le téléamorçage sera redémarré plus tard.
'Error 2512 'L’appel du serveur de téléamorçage a échoué.
'Error 2513 'Impossible de se connecter au serveur de téléamorçage.
'Error 2514 'Impossible d’ouvrir le fichier image sur le serveur de téléamorçage.
'Error 2515 'Connexion au serveur de démarrage à distance...
'Error 2516 'Connexion au serveur de démarrage à distance...
'Error 2517 'Le service de téléamorçage a été arrêté  'reportez-vous au journal d’erreur pour connaître la cause du problème.
'Error 2518 'L’initialisation du téléamorçage a échoué  'reportez-vous au journal d’erreur pour connaître la cause du problème.
'Error 2519 'Une seconde connexion à une ressource de téléamorçage n’est pas autorisée.
'Error 2550 'Le service Explorateur d’ordinateur a été configuré avec MaintainServerList=No.
'Error 2610 'Le service n’a pas pu démarrer car aucune des cartes réseau n’a démarré avec ce service.
'Error 2611 'Le service n’a pas pu démarrer du fait d’informations de démarrage erronées dans le registre.
'Error 2612 'Le service n’a pas pu démarrer car sa base de données est absente ou endommagée.
'Error 2613 'Le service n’a pas pu démarrer car le partage RPLFILES est absent.
'Error 2614 'Le service n’a pas pu démarrer car le groupe RPLUSER est absent.
'Error 2615 'Impossible d’énumérer les enregistrements du service.
'Error 2616 'L’enregistrement des informations sur la station de travail a été endommagé.
'Error 2617 'L’enregistrement de la station de travail n’a pas été trouvé.
'Error 2618 'Le nom de la station de travail est utilisé par une autre station de travail.
'Error 2619 'L’enregistrement des informations sur le profil a été endommagé.
'Error 2620 'L’enregistrement du profil n’a pas été trouvé.
'Error 2621 'Le nom du profil est utilisé par un autre profil.
'Error 2622 'Il y a des stations de travail qui utilisent ce profil.
'Error 2623 'L’enregistrement des informations sur la configuration a été endommagé.
'Error 2624 'L’enregistrement de la configuration n’a pas été trouvé.
'Error 2625 'L’enregistrement de l’information sur l’ID de la carte a été endommagé.
'Error 2626 'Une erreur de service interne est survenue.
'Error 2627 'L’enregistrement de l’information sur l’ID du fabricant a été endommagé.
'Error 2628 'L’enregistrement de l’information sur le bloc d’amorçage a été endommagé.
'Error 2629 'Le compte d’utilisateur pour l’enregistrement de cette station de travail est manquant.
'Error 2630 'Le groupe local RPLUSER n’a pas pu être trouvé.
'Error 2631 'L’enregistrement du bloc d’amorçage n’a pas été trouvé.
'Error 2632 'Le profil choisi est incompatible avec cette station de travail.
'Error 2633 'L’id de carte réseau est utilisée par une autre station de travail.
'Error 2634 'Il y a des profils qui utilisent cette configuration.
'Error 2635 'Il y a des profils ou des configurations de stations de travail qui utilisent cette station de travail.
'Error 2636 'Le service n’a pas pu sauvegarder la base de données d’amorçage à distance.
'Error 2637 'L’enregistrement de la carte n’a pas été trouvé.
'Error 2638 'L’enregistrement du fournisseur n’a pas été trouvé.
'Error 2639 'Le nom du fournisseur est utilisé par un autre enregistrement de fournisseur.
'Error 2640 '(nom d’amorçage, ID de fournisseur) est utilisé par un autre enregistrement du bloc d’amorçage.
'Error 2641 'Le nom de configuration est utilisé par une autre configuration.
'Error 2660 'La base de données interne conservée par le service Dfs est endommagée
'Error 2661 'Un des enregistrements de la base de données Dfs interne est endommagé
'Error 2662 'Il n’existe aucun nom DFS dont le chemin d’entrée correspond au chemin donné
'Error 2663 'Une racine ou un lien portant ce nom existent déjà
'Error 2664 'Le partage de serveur spécifié existe déjà dans le système de fichiers distribués (DFS)
'Error 2665 'Le partage de serveur indiqué ne prend pas en charge l’espace de noms DFS indiqué
'Error 2666 'L’opération n’est pas valide sur cette partie de l’espace de noms
'Error 2667 'L’opération n’est pas valide sur cette partie de l’espace de noms
'Error 2668 'L’opération est ambiguë car le lien a plusieurs serveurs
'Error 2669 'Impossible de créer un lien
'Error 2670 'Le Serveur ne reconnaît pas le système de fichiers distribués DFS
'Error 2671 'Le chemin de changement de nom de cible spécifié n’est pas valide
'Error 2672 'Le lien DFS (système de fichiers distribués) spécifié est déconnecté
'Error 2673 'Le serveur spécifié n’est pas un serveur pour ce lien
'Error 2674 'Un cycle a été détecté dans le nom DFS (système de fichiers distribués)
'Error 2675 'Cette opération n’est pas prise en charge par un Serveur DFS (système de fichiers distribués)
'Error 2676 'Ce lien est déjà pris en charge par le partage de serveur de partage spécifié
'Error 2677 'Impossible de supprimer le dernier partage de serveur qui prend en charge cette racine ou ce lien
'Error 2678 'L’opération n’est pas prise en charge par le lien Inter-DFS
'Error 2679 'L’état interne du service Dfs est devenu inconsistant
'Error 2680 'Le service Dfs a été installé sur le serveur spécifié
'Error 2681 'Les données DFS en cours de réconciliation sont identiques
'Error 2682 'La racine Dfs ne peut pas être effacée - désinstallez DFS si cela est demandé
'Error 2683 'Un répertoire parent ou enfant du partage est déjà dans un Dfs
'Error 2690 'Erreur interne Dfs
'Error 2691 'Cet ordinateur est déjà lié à un domaine.
'Error 2692 'Cet ordinateur n’est actuellement pas lié à un domaine.
'Error 2693 'Cet ordinateur est un contrôleur de domaine et ne peut pas être ôté d’un domaine.
'Error 2694 'Le contrôleur de domaine de destination ne prend pas en charge la création de comptes d’ordinateur dans les unités d’organisation.
'Error 2695 'Le nom de groupe de travail spécifié n’est pas valide.
'Error 2696 'Le nom d’ordinateur spécifié est incompatible avec le langage par défaut utilisé sur le contrôleur de domaine.
'Error 2697 'Le compte d’ordinateur spécifié est introuvable. Contactez un administrateur pour vérifier si le compte fait partie du domaine. Si le compte a été supprimé, quittez le domaine, redémarrez, puis rejoignez le domaine.
'Error 2698 'Cette version de Windows ne peut pas se joindre à un domaine.
'Error 2699 'Échec d’une tentative de résolution du nom DNS d’un contrôleur de domaine dans le domaine sur le point d’être joint. Veuillez vérifier que ce client est configuré pour accéder à un serveur DNS pouvant résoudre des noms DNS dans le domaine cible. Pour plus d’in
'Error 2700 'Cet appareil est joint à Azure AD. Pour joindre un domaine Active Directory, vous devez d'abord accéder aux paramètres et déconnecter votre appareil de votre réseau professionnel ou scolaire.
'Error 2701 'Le mot de passe doit être modifié à la prochaine ouverture de session
'Error 2702 'compte verrouillé
'Error 2703 'Le mot de passe est trop long
'Error 2704 'Le mot de passe ne respecte pas la stratégie de complexité
'Error 2705 'Le mot de passe ne répond pas aux exigences des dll du filtre
'Error 2709 'Informations de réalisation de jonction hors connexion introuvables.
'Error 2710 'Informations de réalisation de jonction hors connexion incorrectes.
'Error 2711 'Impossible de créer les informations de jonction hors connexion. Vérifiez que vous pouvez accéder à l’emplacement du chemin d’accès spécifié et que vous disposez des autorisations pour modifier son contenu. Il peut s’avérer nécessaire d’exécuter l’opération en
'Error 2712 'Les informations de jonction de domaine enregistrées sont incomplètes ou incorrectes.
'Error 2713 'L’opération de jonction hors connexion est terminée mais un redémarrage est nécessaire.
'Error 2714 'Aucune opération de jonction hors connexion en attente.
'Error 2715 'Impossible de définir une ou plusieurs valeurs demandées de nom d’ordinateur ou de domaine sur l’ordinateur local.
'Error 2716 'Impossible de vérifier le nom d’hôte de l’ordinateur actuel par rapport à la valeur enregistrée dans les informations de réalisation de jonction.
'Error 2717 'Impossible de charger la ruche du Registre hors connexion spécifiée. Vérifiez que vous pouvez accéder à l’emplacement du chemin d’accès spécifié et que vous disposez des autorisations pour modifier son contenu. Il peut s’avérer nécessaire d’exécuter l’opératio
'Error 2718 'Les conditions de sécurité minimales de la session pour cette opération n’ont pas été respectées.
'Error 2719 'La version de l’objet BLOB de provisioning de compte d’ordinateur n’est pas prise en charge.
'Error 2720 'Le contrôleur de domaine spécifié ne correspond pas aux critères de version pour cette opération. Sélectionnez un contrôleur capable d’émettre des revendications.
'Error 2721 'Cette opération nécessite la présence d’un contrôleur de domaine prenant en charge LDAP. Sélectionnez un contrôleur de domaine compatible LDAP.
'Error 2722 'Aucun contrôleur de domaine satisfaisant aux critères de version pour cette opération n’a été trouvé. Assurez-vous qu’un contrôleur de domaine en mesure d’émettre des revendications est disponible.
'Error 2723 'La version de Windows de l’image indiquée ne prend pas en charge l’allocation.
'Error 2724 'Le nom d’ordinateur ne peut pas être joint au domaine.
'Error 2725 'Le contrôleur de domaine ne répond pas à la configuration requise par la version pour cette opération. Voir http://go.microsoft.com/fwlink/?LinkId=294288 pour plus d’informations.
'Error 2726 'La machine locale ne permet pas d'interroger  les secrets du LSA en texte brut.
'Error 2727 'Impossible de quitter le domaine Azure AD auquel cet ordinateur est joint. Consultez le journal des événements pour des informations détaillées sur cette erreur.
'Error 2999 'Il s’agit de la dernière erreur dans l’intervalle NERR.
'Error 3000 'Le moniteur d’impression spécifié est inconnu.
'Error 3001 'Le pilote d’imprimante spécifié est en cours d’utilisation.
'Error 3002 'Le fichier spouleur n’a pas été trouvé.
'Error 3003 'Un appel à StartDocPrinter n’a pas été opéré.
'Error 3004 'Un appel AddJob est resté sans suite.
'Error 3005 'Le processeur d’impression spécifié a déjà été installé.
'Error 3006 'Le moniteur d’impression spécifié a déjà été installé.
'Error 3007 'Le moniteur d’impression spécifié ne possède pas les fonctions nécessaires.
'Error 3008 'Le moniteur d’impression spécifié est en cours d’utilisation.
'Error 3009 'L’opération demandée n’est pas autorisée lorsqu’il y a des travaux dans la file d’impression.
'Error 3010 'L’opération demandée est réussie. Les modifications ne seront pas effectives avant que le système ne soit réamorcé.
'Error 3011 'L’opération demandée est réussie. Les modifications ne seront pas effectives avant que le service ne soit redémarré.
'Error 3012 'Aucune imprimante n’a été trouvée.
'Error 3013 'Le pilote d’imprimante est instable.
'Error 3014 'Le pilote d’imprimante endommage le système.
'Error 3015 'Le package du pilote d’imprimante spécifié est actuellement utilisé.
'Error 3016 'Impossible de trouver un package de pilotes principal requis par le package de pilotes de l’imprimante.
'Error 3017 'Échec de l’opération demandée. Il est nécessaire de redémarrer le système pour restaurer les modifications apportées.
'Error 3018 'Échec de l’opération demandée. Un redémarrage du système a été initié pour restaurer les modifications apportées.
'Error 3019 'Le pilote d’imprimante spécifié est introuvable dans le système et doit être téléchargé.
'Error 3020 'Le travail d’impression demandé n’a pas pu être imprimé. Une mise à jour du système d’impression impose de renvoyer le travail.
'Error 3021 'Le pilote d’imprimante ne contient pas de manifeste valide, ou contient trop de manifestes.
'Error 3022 'Impossible de partager l’imprimante spécifiée.
'Error 3023 'Un problème de configuration dans un fichier de commandes d’arrêt spécifié par l’utilisateur n’a pas empêché le démarrage du service Onduleur.
'Error 3025 'Un secteur défectueux a été corrigé sur le lecteur %1 sans perte de données. Exécutez sans tarder CHKDSK pour restaurer les performances et reconstruire de nouveau le pool de secteurs de réserve du volume.  La correction logicielle a eu lieu lors du traitement
'Error 3026 'Une erreur disque s’est produite sur le volume HPFS du lecteur %1. Cette erreur s’est produite lors du traitement d’une demande distante.
'Error 3027 'La base de données des comptes d’utilisateurs (NET.ACC) est endommagée. Le système de sécurité locale remplace le fichier NET.ACC endommagé par la copie de sauvegarde réalisée le %1 à %2. Toutes les mises à jour postérieures de la base de données UAS sont perd
'Error 3028 'La base de données des comptes d’utilisateurs (NET.ACC) est absente. Le système de sécurité locale restaure la copie de sauvegarde réalisée le %1 à %2. Toutes les mises à jour postérieures de la base de données UAS sont perdues.
'Error 3029 'La sécurité locale n’a pas pu démarrer car la base de données des comptes d’utilisateurs (NET.ACC) est soit manquante soit endommagée, et aucune copie de sauvegarde utilisable n’est disponible.  LE SYSTÈME N’EST PAS PROTÉGÉ.
'Error 3030 'Le serveur ne peut pas exporter le répertoire %1 en direction du client %2. Ce répertoire est exporté depuis un autre serveur.
'Error 3031 'Le serveur de réplication n’a pas pu mettre à jour le répertoire %2 à partir de la source sur %3 en raison de l’erreur %1.
'Error 3032 'Le maître d’opérations %1 n’a envoyé aucun avis de mise à jour pour l’annuaire %2 en temps voulu.
'Error 3033 'L’utilisateur %1 a dépassé la limite de compte %2 sur le serveur %3.
'Error 3034 'Le contrôleur principal du domaine %1 a subi une défaillance.
'Error 3035 'Échec de l'authentification avec %2, un contrôleur de domaine Windows du domaine %1.
'Error 3036 'Le duplicateur a tenté sans succès d’ouvrir une session sur %2 sous le nom %1.
'Error 3037 '@I *HORAIRES D’ACCÈS
'Error 3038 'Le duplicateur n’a pas pu accéder à %2 sur %3 en raison de l’erreur système %1.
'Error 3039 'Dépassement de la limite du duplicateur pour les fichiers dans un répertoire.
'Error 3040 'Dépassement de la limite du duplicateur pour la profondeur de l’arborescence.
'Error 3041 'Le duplicateur ne peut pas mettre à jour le répertoire %1. Son paramètre INTEGRITY a la valeur TREE, et un processus l’utilise en tant que répertoire en cours.
'Error 3042 'L’erreur réseau %1 s’est produite.
'Error 3045 'L’erreur système %1 s’est produite.
'Error 3046 'Accès impossible  'un utilisateur conduit déjà une session, et l’argument TRYUSER spécifie l’option NO.
'Error 3047 'Impossible de trouver le chemin IMPORT %1.
'Error 3048 'Impossible de trouver le chemin EXPORT %1.
'Error 3049 'Des données dupliquées ont changé dans le répertoire %1.
'Error 3050 'L’opération a été suspendue.
'Error 3051 'Le Registre ou les informations que vous venez d’entrer contiennent une valeur non autorisée pour "%1".
'Error 3052 'Le paramètre requis n’a pas été fourni sur la ligne de commande ou dans le fichier de configuration.
'Error 3053 'LAN Manager ne reconnaît pas "%1" en tant qu’option valide.
'Error 3054 'Une demande de ressource n’a pu être satisfaite.
'Error 3055 'La configuration du système présente un problème.
'Error 3056 'Une erreur système s’est produite.
'Error 3057 'Une erreur de cohérence interne s’est produite.
'Error 3058 'Le fichier de configuration ou la ligne de commande contient une option ambiguë.
'Error 3059 'Le fichier de configuration ou la ligne de commande contient un paramètre en double.
'Error 3060 'Le service n’a pas répondu aux commandes et a été arrêté par la fonction DosKillProc.
'Error 3061 'Une erreur s’est produite lors d’une tentative d’exécution du programme du service.
'Error 3062 'Le démarrage du sous-service a échoué.
'Error 3063 'La valeur ou l’utilisation des options suivantes suscite un conflit  '%1.
'Error 3064 'Il y a un problème au niveau du fichier.
'Error 3070 'mémoire
'Error 3071 'espace disque
'Error 3072 'thread
'Error 3073 'processus
'Error 3074 'Défaillance de la sécurité.
'Error 3075 'Répertoire racine LAN Manager incorrect ou absent.
'Error 3076 'Le logiciel réseau n’est pas installé.
'Error 3077 'Le serveur n’a pas été lancé.
'Error 3078 'Le serveur ne peut pas accéder à la base de données des comptes d’utilisateurs (NET.ACC).
'Error 3079 'L’arborescence LANMAN contient des fichiers incompatibles.
'Error 3080 'Le répertoire LANMAN\LOGS n’est pas valide.
'Error 3081 'Le domaine spécifié n’a pas pu être utilisé.
'Error 3082 'Le nom d’ordinateur est utilisé en tant qu’alias pour les messages sur un autre ordinateur.
'Error 3083 'L’annonce du nom du serveur a échoué.
'Error 3084 'La base de données des comptes d’utilisateurs n’est pas configurée convenablement.
'Error 3085 'Le serveur ne contrôle pas l’accès au niveau utilisateur.
'Error 3087 'La station de travail n’est pas configurée convenablement.
'Error 3088 'Vous trouverez des détails à ce sujet dans votre journal des erreurs.
'Error 3089 'Il est impossible d’écrire des données dans ce fichier.
'Error 3090 'Le fichier ADDPAK est endommagé. Supprimez LANMAN\NETPROG\ADDPAK.SER et appliquez à nouveau tous les ADDPAKs.
'Error 3091 'Impossible de démarrer le serveur LM386 car CACHE.EXE ne s’exécute pas.
'Error 3092 'Il n’existe aucun compte pour cet ordinateur dans la base de données de la sécurité.
'Error 3093 'Cet ordinateur n’est pas membre du groupe SERVERS.
'Error 3094 'Le groupe SERVERS ne figure pas dans la base de données de la sécurité locale.
'Error 3095 'Cet ordinateur est configuré en tant que membre d’un groupe de travail, et non en tant que membre d’un domaine. Il n’est pas nécessaire d’exécuter le service Accès réseau dans cette configuration.
'Error 3096 'Le contrôleur de domaine principal pour ce domaine est introuvable.
'Error 3097 'Cet ordinateur est configuré pour être le contrôleur de domaine principal de son domaine. Cependant, l’ordinateur %1 demande actuellement à être le contrôleur de domaine principal du domaine.
'Error 3098 'L’authentification du service avec le contrôleur principal de domaine a échoué.
'Error 3099 'La date de création ou le numéro de série de la base de données de la sécurité présente un problème.
'Error 3100 'Une erreur du logiciel réseau a fait échouer l’opération.
'Error 3101 'Une ressource système contrôlée par l’option %1 est épuisée.
'Error 3102 'Le service n’a pas réussi à obtenir un verrou à long terme sur le segment des NCB. Le code d’erreur est fourni dans les données.
'Error 3103 'Le service n’a pas réussi à retirer le verrou à long terme du segment des NCB. Le code d’erreur est fourni dans les données.
'Error 3104 'Une erreur a affecté l’arrêt du service %1. Le code d’erreur de NetServiceControl est fourni dans les données.
'Error 3105 'Une erreur d’exécution système dans le chemin %1 a empêché l’initialisation. Le code d’erreur système est fourni dans les données.
'Error 3106 'Réception d’un bloc de contrôle réseau (NCB) inattendu. Le NCB est fourni dans les données.
'Error 3107 'Le réseau n’a pas été lancé.
'Error 3108 'Un appel DosDevIoctl ou DosFsCtl à NETWKSTA.SYS a échoué. Les données sont présentées sous le format  'DWORD  approx CS:IP de l’appel à ioctl ou fsctl WORD   code d’erreur WORD   numéro ioctl ou fsctl
'Error 3109 'Création ou ouverture du sémaphore système %1 impossible. Le code d’erreur est fourni dans les données.
'Error 3110 'Une erreur en ouverture/création du fichier %1 a empêché l’initialisation. Le code d’erreur système est fourni dans les données.
'Error 3111 'Une erreur NetBIOS inattendue s’est produite. Le code d’erreur est fourni dans les données.
'Error 3112 'Un bloc de message serveur (SMB) non autorisé a été reçu. Le SMB est fourni dans les données.
'Error 3113 'L’initialisation a échoué car le service demandé, %1, n’a pas pu être démarré.
'Error 3114 'Un dépassement de capacité d’une zone tampon a provoqué la perte de quelques enregistrements du journal des erreurs.
'Error 3120 'Les valeurs spécifiées pour les paramètres d’initialisation contrôlant l’usage des ressources (en dehors des zones tampon réseau) mobilisent trop de mémoire.
'Error 3121 'Le serveur ne peut pas augmenter la taille d’un segment de mémoire.
'Error 3122 'L’initialisation a échoué car le fichier de comptes %1 est soit incorrect, soit absent.
'Error 3123 'L’initialisation a échoué car le réseau %1 n’a pas été démarré.
'Error 3124 'Le serveur n’a pas pu démarrer. Les paramètres chdev doivent être tous les trois soit nuls, soit différents de zéro.
'Error 3125 'Une demande d’API distante a été arrêtée en raison de la chaîne de description non valide suivante  '%1.
'Error 3126 'Le réseau %1 a épuisé ses NCB. Il faut peut-être augmenter les NCB pour ce réseau. Les informations suivantes contiennent le nombre de NCB soumis par le serveur lorsque cette erreur s’est produite :
'Error 3127 'Le serveur ne peut pas créer la boîte aux lettres %1 nécessaire pour envoyer le message d’alerte ReleaseMemory. L’erreur reçue est :
'Error 3128 'Le serveur n’a pas enregistré l’alerte ReleaseMemory, à adresser au destinataire %1. Le code d’erreur de  NetAlertStart est fourni dans les données.
'Error 3129 'Le serveur ne peut pas mettre à jour le fichier calendrier AT. Ce fichier est endommagé.
'Error 3130 'Le serveur a rencontré une erreur en appelant  NetIMakeLMFileName. Le code d’erreur est fourni dans les données.
'Error 3131 'Une erreur d’exécution système dans le chemin %1 a empêché l’initialisation. Il n’y a pas assez de mémoire pour lancer le processus. Le code d’erreur système est dans les données.
'Error 3132 'Le verrouillage à long terme de zones tampon du serveur a échoué. Vérifiez l’espace disponible sur le disque d’échange et redémarrez le système pour démarrer le serveur.
'Error 3140 'De nombreuses répétitions consécutives d’une même erreur de bloc de contrôle réseau (NCB) ont provoqué l’arrêt du service. Le dernier NCB erroné est fourni dans les données brutes suivantes.
'Error 3141 'Le serveur de messages s’est arrêté en raison d’un verrou sur son segment de données partagées.
'Error 3150 'L’ouverture du fichier journal des messages, %1, ou l’écriture dans ce fichier a provoqué une erreur de système de fichiers. Cette erreur a arrêté l’enregistrement des messages. Le code d’erreur est fourni dans les données.
'Error 3151 'Une erreur d’appel VIO système empêche l’affichage des boîtes de message. Le code d’erreur est fourni dans les données.
'Error 3152 'Un bloc de message serveur (SMB) non autorisé a été reçu. Le SMB est fourni dans les données.
'Error 3160 'Le segment d’informations de station de travail dépasse 64 Ko. Sa taille est fournie ci-dessous en format DWORD :
'Error 3161 'La station de travail n’a pas pu obtenir le numéro de nom d’ordinateur.
'Error 3162 'La station de travail n’a pas pu initialiser le thread Async NetBios. Le code d’erreur est fourni dans les données.
'Error 3163 'La station de travail n’a pas pu ouvrir le segment partagé initial. Le code d’erreur est fourni dans les données.
'Error 3164 'Le tableau d’hôtes de la station de travail est saturé.
'Error 3165 'Un SMB de boîte aux lettres incorrect a été reçu. Le SMB est fourni dans les données.
'Error 3166 'La station de travail a rencontré une erreur en essayant de lancer l’UAS. Le code d’erreur est fourni dans les données.
'Error 3167 'La station de travail a rencontré une erreur en répondant à une demande de revalidation SSI. Le code de fonction et les codes d’erreur sont fournis dans les données.
'Error 3170 'Le service Alertes a rencontré un problème en créant la liste des destinataires des alertes. Le code d’erreur est %1.
'Error 3171 'Le développement de %1 en tant que nom de groupe a provoqué une erreur. Essayez de fractionner le groupe en plusieurs sous-groupes de petite taille.
'Error 3172 'Une erreur a affecté l’envoi à %2 du message d’alerte - ( %3 ) Le code d’erreur est %1.
'Error 3173 'Une erreur a affecté la création ou la lecture de la boîte des messages d’alertes Le code d’erreur est %1.
'Error 3174 'Le serveur n’a pas pu lire le fichier calendrier AT.
'Error 3175 'Le serveur a trouvé un enregistrement de calendrier AT non valide.
'Error 3176 'Le fichier calendrier AT étant introuvable, le serveur en a créé un.
'Error 3177 'Le serveur n’a pas pu accéder au réseau %1 avec NetBiosOpen.
'Error 3178 'Le processeur des commandes AT n’a pas pu exécuter %1.
'Error 3180 'AVERTISSEMENT  'en raison d’une erreur en écriture différée, le lecteur %1 contient maintenant des données endommagées. Le cache est arrêté.
'Error 3181 'Un secteur défectueux a été corrigé sur le lecteur %1 sans perte de données. Exécutez sans tarder CHKDSK pour restaurer les performances et reconstruire de nouveau le pool de secteurs de réserve du volume.  La correction logicielle a eu lieu lors du traitement
'Error 3182 'Une erreur disque s’est produite sur le volume HPFS du lecteur %1. Cette erreur s’est produite lors du traitement d’une demande distante.
'Error 3183 'La base de données des comptes d’utilisateurs (NET.ACC) est endommagée. Le système de sécurité locale remplace le fichier NET.ACC endommagé par la copie de sauvegarde réalisée à %1. Toutes les mises à jour postérieures de la base de données UAS sont perdues.
'Error 3184 'La base de données des comptes d’utilisateurs (NET.ACC) est absente. Le système de sécurité locale restaure la copie de sauvegarde réalisée à %1. Toutes les mises à jour postérieures de la base de données UAS sont perdues
'Error 3185 'La sécurité locale n’a pas pu démarrer car la base de données des comptes d’utilisateurs (NET.ACC) est soit manquante soit endommagée, et aucune copie de sauvegarde utilisable n’est disponible.  LE SYSTÈME N’EST PAS PROTÉGÉ.
'Error 3186 'La sécurité locale n’a pas pu être démarrée en raison d’une erreur survenue  lors de l’initialisation. Le code d’erreur renvoyé est %1.  LE SYSTÈME N’EST PAS PROTÉGÉ.
'Error 3190 'Une erreur interne NetWksta s’est produite  '%1
'Error 3191 'Le redirecteur a épuisé la ressource  '%1.
'Error 3192 'Une erreur SMB s’est produite sur la connexion à %1. L’en-tête SMB est fournie dans les données.
'Error 3193 'Une erreur de circuit virtuel a affecté la session sur %1. La commande NCB et le code de retour sont fournis dans les données.
'Error 3194 'Déconnexion d’une session bloquée sur %1.
'Error 3195 'Une erreur NCB s’est produite (%1). Le NCB est fourni dans les données.
'Error 3196 'Une opération d’écriture sur %1 a échoué. Il est possible que des données soient perdues.
'Error 3197 'La réinitialisation du pilote %1 n’a pas réussi à terminer le NCB. Le NCB est fourni dans les données.
'Error 3198 'La quantité de ressource %1 demandée dépasse le maximum. La quantité maximale a été allouée.
'Error 3204 'Le serveur n’a pas pu créer un thread. Il faut augmenter la valeur du paramètre THREADS dans CONFIG.SYS.
'Error 3205 'Le serveur n’a pas pu refermer %1. Ce fichier est probablement endommagé.
'Error 3206 'Le duplicateur ne peut pas mettre à jour le répertoire %1. Son paramètre INTEGRITY a la valeur TREE, et un processus l’utilise en tant que répertoire en cours.
'Error 3207 'Le serveur ne peut pas exporter le répertoire %1 en direction du client %2. Ce répertoire est exporté depuis un autre serveur.
'Error 3208 'Le serveur de réplication n’a pas pu mettre à jour le répertoire %2 à partir de la source sur %3 en raison de l’erreur %1.
'Error 3209 'Le maître d’opérations %1 n’a envoyé aucun avis de mise à jour pour l’annuaire %2 en temps voulu.
'Error 3210 'Cet ordinateur ne peut pas authentifier avec %2, un contrôleur de domaine Windows pour le domaine %1. Cet ordinateur pourrait par conséquent refuser les demandes d’ouvertures de session. Cette impossibilité d’authentification pourrait avoir été causée par un a
'Error 3211 'Le duplicateur a tenté sans succès d’ouvrir une session sur %2 sous le nom %1.
'Error 3212 'L’erreur réseau %1 s’est produite.
'Error 3213 'Dépassement de la limite du duplicateur pour les fichiers dans un répertoire.
'Error 3214 'Dépassement de la limite du duplicateur pour la profondeur de l’arborescence.
'Error 3215 'Un message non reconnu a été reçu dans une boîte aux lettres (mailslot).
'Error 3216 'L’erreur système %1 s’est produite.
'Error 3217 'Accès impossible  'un utilisateur conduit déjà une session, et l’argument TRYUSER spécifie l’option NO.
'Error 3218 'Impossible de trouver le chemin IMPORT %1.
'Error 3219 'Impossible de trouver le chemin EXPORT %1.
'Error 3220 'L’erreur système %1 a empêché le duplicateur de mettre à jour le fichier signal dans le répertoire %2.
'Error 3221 'Erreur de tolérance de pannes disque  %1
'Error 3222 'Le duplicateur n’a pas pu accéder à %2 sur %3 en raison de l’erreur système %1.
'Error 3223 'Le contrôleur principal du domaine %1 semble avoir subi une défaillance.
'Error 3224 'Le changement du mot de passe du compte ordinateur pour le compte %1 a échoué avec l’erreur suivante :
'%2
'Error 3225 'Erreur lors de la mise à jour des informations d’ouverture ou de fermeture de session pour %1.
'Error 3226 'Erreur lors de la synchronisation avec le contrôleur principal de domaine %1
'Error 3227 'L 'installation de la session sur le contrôleur de domaine Windows %1 pour le domaine %2 a échoué car %1 ne prend pas en charge la signature ni la clôture de la session Netlogon.  Vous devez soit mettre à niveau le contrôleur de domaine soit paramétrer l'entrée
'Error 3230 'Une panne de courant a été détectée.
'Error 3231 'Le service Onduleur a arrêté le serveur.
'Error 3232 'Le service Onduleur n’a pas terminé l’exécution du fichier de commandes d’arrêt spécifié par l’utilisateur.
'Error 3233 'Il est impossible d’ouvrir le pilote Onduleur. Le code d’erreur est fourni dans les données.
'Error 3234 'Le courant a été rétabli.
'Error 3235 'Un problème de configuration dans un fichier de commandes d’arrêt spécifié d’arrêt spécifié par l’utilisateur.
'Error 3236 'Le service Onduleur n’a pas pu exécuter le fichier de commandes d’arrêt %1 spécifié par l’utilisateur. Le code d’erreur est fourni dans les données.
'Error 3250 'L’initialisation a échoué en raison d’un paramètre manquant ou non valide dans le fichier de configuration  '%1.
'Error 3251 'L’initialisation a échoué en raison d’une ligne non valide dans le fichier de configuration %1. La ligne erronée est fournie dans les données.
'Error 3252 'L’initialisation a échoué en raison d’une erreur dans le fichier de configuration %1.
'Error 3253 'Le fichier %1 a été modifié après l’initialisation. Le chargement du bloc d’amorçage a été arrêté temporairement.
'Error 3254 'Les fichiers ne correspondent pas au fichier de configuration du bloc d’amorçage, %1. Modifiez les définitions BASE et ORG ou  l’ordre des fichiers.
'Error 3255 'L’initialisation a échoué car la bibliothèque de liens dynamiques %1 a renvoyé un numéro de version incorrect.
'Error 3256 'Une erreur irrémédiable a été rencontrée dans la bibliothèque de liens dynamiques du service.
'Error 3257 'Le système a renvoyé un code d’erreur inattendu. Le code d’erreur est fourni dans les données.
'Error 3258 'Le fichier du journal des erreurs de la tolérance de pannes, RACINELAN\LOGS\FT.LOG, dépasse 64 Ko.
'Error 3259 'Le bit de mise à jour en cours du fichier du journal des erreurs de la tolérance de pannes, RACINELAN\LOGS\FT.LOG, était à 1 lors de l’ouverture, ce qui signifie que le système était tombé en panne en travaillant sur le journal des erreurs.
'Error 3260 'Cet ordinateur a été joint correctement au domaine '%1'.
'Error 3261 'Cet ordinateur a été correctement joint à un groupe de travail '%1'.
'Error 3299 '%1 %2 %3 %4 %5 %6 %7 %8 %9.
'Error 3301 'IPC distant
'Error 3302 'Administration à distance
'Error 3303 'Partage de serveur d’accès
'Error 3304 'Une erreur réseau s’est produite.
'Error 3400 'Mémoire insuffisante pour lancer le service Station de travail.
'Error 3401 'Une erreur a affecté la lecture du paramètre NETWORKS de LANMAN.INI.
'Error 3402 'Cet argument n’est pas valide  '%1.
'Error 3403 'Le %1 paramètre NETWORKS de LANMAN.INI présente une erreur de syntaxe. Il sera ignoré.
'Error 3404 'Il y a trop de paramètres NETWORKS dans LANMAN.INI.
'Error 3406 'Une erreur a affecté l’ouverture du pilote de périphérique réseau %1 = %2.
'Error 3407 'Le pilote de périphérique %1 a envoyé une réponse BiosLinkage incorrecte.
'Error 3408 'Impossible d’exécuter le programme sur ce système d’exploitation.
'Error 3409 'Le redirecteur est déjà installé.
'Error 3410 'Installation de NETWKSTA.SYS version %1.%2.%3 (%4)
'Error 3411 'Une erreur a affecté l’installation de NETWKSTA.SYS.  Appuyez sur ENTRÉE pour continuer.
'Error 3412 'Problème de liaison du solveur.
'Error 3413 'Votre horaire d’accès à %1 expire à %2. Fermez votre session après avoir tout mis en ordre.
'Error 3414 'Vous serez déconnecté automatiquement à %1.
'Error 3415 'Votre horaire d’accès à %1 est expiré.
'Error 3416 'Votre horaire d’accès à %1 est expiré depuis %2.
'Error 3417 'AVERTISSEMENT  'Vous avez jusqu’à %1 pour fermer votre session. Passé ce délai, votre session sera déconnectée automatiquement, et vous risquez de perdre des données s’il reste des fichiers ou des périphériques ouverts.
'Error 3418 'AVERTISSEMENT  'Vous devez fermer votre session sur %1 maintenant. Vous disposez de deux minutes avant la déconnexion automatique.
'Error 3419 'En cas de déconnexion forcée, vous risquez de perdre des données car vous avez encore des fichiers ou des périphériques ouverts.
'Error 3420 'Partage par défaut à usage interne
'Error 3421 'Service Affichage des messages
'Error 3500 'La commande s’est terminée correctement.
'Error 3501 'Vous avez utilisé une option non valide.
'Error 3502 'L’erreur système %1 s’est produite.
'Error 3503 'La commande contient un nombre d’arguments non valide.
'Error 3504 'Des erreurs ont affecté l’exécution de la commande.
'Error 3505 'Vous avez utilisé une option avec une valeur non valide.
'Error 3506 'L’option %1 est inconnue.
'Error 3507 'L’option %1 est ambiguë.
'Error 3510 'Une commande a été utilisée avec des commutateurs incompatibles.
'Error 3511 'Le sous-programme %1 est introuvable.
'Error 3512 'Le logiciel requiert une version plus récente du système d’exploitation.
'Error 3513 'Il y a plus de données disponibles que Windows ne peut en renvoyer.
'Error 3514 'Vous obtiendrez une aide supplémentaire en entrant NET HELPMSG %1.
'Error 3515 'Cette commande ne peut s’employer que sur un contrôleur de domaine Windows.
'Error 3516 'Cette commande ne peut être utilisée sur un contrôleur de domaine Windows.
'Error 3520 'Les services Windows suivants ont été lancés :
'Error 3521 'Le service %1 n’est pas lancé.
'Error 3522 'Le service %1 démarre
'Error 3523 'Le service %1 n’a pas pu être lancé.
'Error 3524 'Le service %1 a démarré.
'Error 3525 'L’arrêt du service Station de travail arrête aussi le service Serveur.
'Error 3526 'La station de travail a des fichiers ouverts.
'Error 3527 'Le service %1 s’arrête
'Error 3528 'Le service %1 n’a pas pu être arrêté.
'Error 3529 'Le service %1 a été arrêté.
'Error 3530 'Les services suivants dépendent du service %1. L’arrêt du service %1 arrête aussi ces services.
'Error 3533 'Le service démarre ou s’arrête. Faites un nouvel essai plus tard.
'Error 3534 'Le service n’a pas signalé d’erreur.
'Error 3535 'Une erreur a affecté la commande du périphérique.
'Error 3536 'Le service %1 a été restauré.
'Error 3537 'Le service %1 a été suspendu.
'Error 3538 'Impossible de restaurer le service %1.
'Error 3539 'Impossible de suspendre le service %1.
'Error 3540 'La reprise du service %1 est imminente
'Error 3541 'La pause du service %1 est imminente
'Error 3542 '%1 a été restauré.
'Error 3543 '%1 a été suspendu.
'Error 3544 'Le service %1 a été lancé par un autre processus ; son démarrage est imminent.
'Error 3547 'Une erreur spécifique à un service s’est produite  '%1.
'Error 3660 'Ces stations de travail ont des sessions sur ce serveur :
'Error 3661 'Ces stations de travail ont des sessions avec des fichiers ouverts sur ce serveur :
'Error 3666 'Les messages adressés à cet alias sont transmis.
'Error 3670 'Vous possédez les connexions à distance suivantes :
'Error 3671 'La poursuite de cette opération va rompre les connexions.
'Error 3675 'La session de %1 a des fichiers ouverts.
'Error 3676 'Les nouvelles connexions seront mémorisées.
'Error 3677 'Les nouvelles connexions ne seront pas mémorisées.
'Error 3678 'Une erreur s’est produite pendant l’enregistrement de votre profil  'accès refusé. L’état de vos connexions mémorisées n’a pas changé.
'Error 3679 'Une erreur s’est produite lors de la lecture de votre profil.
'Error 3680 'Une erreur s’est produite lors de la restauration de la connexion à %1.
'Error 3682 'Aucun service réseau n’a démarré.
'Error 3683 'La liste est vide.
'Error 3688 'Des utilisateurs ont des fichiers ouverts sur %1. Ces fichiers vont être refermés.
'Error 3689 'Le service Station de travail s’exécute déjà. Windows va ignorer les options de commande concernant ce service.
'Error 3691 'Il y a des fichiers ouverts et/ou des recherches en répertoire non terminées sur la connexion à %1.
'Error 3693 'La demande sera traitée sur contrôleur de domaine du domaine %1.
'Error 3694 'Impossible de supprimer la file partagée pendant qu’elle reçoit un travail d’impression.
'Error 3695 '%1 a une connexion mémorisée à %2.
'Error 3710 'Erreur lors de l’ouverture du fichier d’aide.
'Error 3711 'Le fichier d’aide est vide.
'Error 3712 'Le fichier d’aide est endommagé.
'Error 3713 'Le contrôleur du domaine %1 est introuvable.
'Error 3714 'Cette opération est privilégiée sur les systèmes utilisant d’anciennes versions du logiciel.
'Error 3716 'Type de périphérique inconnu.
'Error 3717 'Le fichier journal est endommagé.
'Error 3718 'Les noms de fichiers programmes doivent se terminer par .EXE.
'Error 3719 'Faute de trouver un partage correspondant, rien n’a été supprimé.
'Error 3720 'Le champ unités-par-semaine de l’enregistrement utilisateur contient une valeur incorrecte.
'Error 3721 'Le mot de passe n’est pas valide pour %1.
'Error 3722 'Une erreur s’est produite lors de l’envoi du message à %1.
'Error 3723 'Le mot de passe ou nom d’utilisateur n’est pas valide pour %1.
'Error 3725 'Une erreur s’est produite lors de la suppression du partage.
'Error 3726 'Le nom d’utilisateur n’est pas valide.
'Error 3727 'Le mot de passe n’est pas valide.
'Error 3728 'Les mots de passe ne correspondent pas.
'Error 3729 'Vos connexions persistantes n’ont pas toutes été restaurées.
'Error 3730 'Ce nom d’ordinateur ou de domaine n’est pas valide.
'Error 3732 'Impossible de définir des autorisations par défaut pour cette ressource.
'Error 3734 'Aucun mot de passe valide n’a été fourni.
'Error 3735 'Aucun nom valide n’a été fourni.
'Error 3736 'Impossible de partager la ressource nommée.
'Error 3737 'La chaîne des autorisations contient des autorisations non valides.
'Error 3738 'Cette opération n’est autorisée que sur les imprimantes et les périphériques de communication.
'Error 3742 '%1 n’est pas un nom d’utilisateur ou de groupe valide.
'Error 3743 'Le serveur n’est pas configuré pour l’administration distante.
'Error 3752 'Aucun utilisateur n’a de session en cours sur ce serveur.
'Error 3753 'L’utilisateur %1 n’est pas membre du groupe %2.
'Error 3754 'L’utilisateur %1 est déjà membre du groupe %2.
'Error 3755 'L’utilisateur %1 n’existe pas.
'Error 3756 'Cette réponse n’est pas valide.
'Error 3757 'Aucune réponse valide n’a été fournie.
'Error 3758 'La liste de destinations fournie ne correspond pas à la liste de destinations de la file d’impression.
'Error 3759 'Impossible de changer votre mot de passe avant %1.
'Error 3760 '%1 n’est pas un jour de la semaine reconnu.
'Error 3761 'Vous avez spécifié un intervalle de temps négatif.
'Error 3762 '%1 n’est pas une heure reconnue.
'Error 3763 '%1 n’est pas un nombre de minutes correct.
'Error 3764 'L’heure fournie n’est pas une heure pleine.
'Error 3765 'Impossible de mélanger les formats 12 et 24 heures.
'Error 3766 '%1 n’est pas un suffixe valide du format 12 heures.
'Error 3767 'Format de date non autorisé.
'Error 3768 'Intervalle de jours non autorisé.
'Error 3769 'Intervalle de temps non autorisé.
'Error 3770 'NET USER contient des arguments non valides. Vérifiez la longueur minimale du mot de passe et/ou les arguments spécifiés.
'Error 3771 'ENABLESCRIPT doit avoir la valeur YES.
'Error 3773 'Un code de pays/région non autorisé a été fourni.
'Error 3774 'Le compte d’utilisateur a été créé mais n’a pas pu être ajouté au groupe local Utilisateurs.
'Error 3775 'Le contexte utilisateur fourni n’est pas valide.
'Error 3776 'La bibliothèque de liens dynamiques %1 n’a pas pu être chargée, ou une erreur s’est produite lorsque le système a tenté de l’utiliser.
'Error 3777 'L’envoi de fichiers n’est plus autorisé.
'Error 3778 'Vous n’êtes pas autorisé à spécifier des chemins pour les ressources ADMIN$ et IPC$.
'Error 3779 'L’utilisateur ou le groupe %1 est déjà membre du groupe local %2.
'Error 3780 'L’utilisateur ou le groupe %1 n’existe pas.
'Error 3781 'L’ordinateur %1 n’existe pas.
'Error 3782 'L’ordinateur %1 existe déjà.
'Error 3783 'L’utilisateur ou groupe global suivant n’existe pas  '%1.
'Error 3784 'Seuls les ressources disques partagées peuvent être marquées comme pouvant être cachées.
'Error 3790 'Le message %1 est introuvable.
'Error 3802 'Cette date de calendrier n’est pas valide.
'Error 3803 'Le répertoire racine LANMAN n’est pas disponible.
'Error 3804 'Impossible d’ouvrir le fichier SCHED.LOG.
'Error 3805 'Le service Serveur n’a pas été lancé.
'Error 3806 'Le numéro d’identification de travail AT n’existe pas.
'Error 3807 'Le fichier calendrier AT est endommagé.
'Error 3808 'La suppression a échoué en raison d’un problème avec le fichier calendrier AT.
'Error 3809 'La ligne de commande ne peut excéder 259 caractères.
'Error 3810 'Le disque étant saturé, la mise à jour du fichier calendrier AT est impossible.
'Error 3812 'Le fichier calendrier AT n’est pas valide. Supprimez-le et créez-en un autre, s.v.p.
'Error 3813 'Le fichier calendrier AT a été supprimé.
'Error 3814 'La syntaxe de cette commande est  ' AT [numéro] [/DELETE] AT heure [/EVERY:date | /NEXT:date] commande  La commande AT programme l’exécution d’un logiciel ou d’une commande à une date et une heure ultérieures sur un serveur. Elle affiche également la liste des
'Error 3815 'La commande AT ne répond pas temporairement. Faites un nouvel essai plus tard.
'Error 3816 'L’antériorité minimale du mot de passe pour des comptes d’utilisateurs ne peut pas être supérieur à l’antériorité maximale du mot de passe.
'Error 3817 'La valeur que vous avez spécifiée n’est pas compatible avec les serveurs exécutant un logiciel de bas niveau. Spécifiez une valeur plus faible.
'Error 3870 '%1 n’est pas un nom d’ordinateur valide.
'Error 3871 '%1 n’est pas un identificateur valide de message réseau Windows.
'Error 3900 'Message de %1 à %2 le %3
'Error 3901 '****
'Error 3902 '**** fin de message inopinée ****
'Error 3905 'Appuyez sur ECHAP pour sortir
'Error 3906 '...
'Error 3910 'L’heure en cours sur %1 est %2
'Error 3911 'L’heure en cours de l’horloge locale est %1 Voulez-vous régler l’horloge de l’ordinateur local en fonction de l’heure de %2 ? %3 :
'Error 3912 'Impossible de trouver un serveur de synchronisation.
'Error 3913 'Impossible de trouver le contrôleur du domaine %1.
'Error 3914 'L’heure locale (GMT%3) à %1 est %2
'Error 3915 'Le répertoire de base de l’utilisateur n’a pu être déterminé.
'Error 3916 'Le répertoire de base de l’utilisateur n’a pas été spécifié.
'Error 3917 'Le répertoire de base spécifié pour l’utilisateur (%1) n’est pas un chemin réseau UNC.
'Error 3918 'Le lecteur %1 est maintenant connecté à %2. Votre répertoire de base est %3\%4.
'Error 3919 'Le lecteur %1 est maintenant connecté à %2.
'Error 3920 'Il n’y a plus de lettres de lecteur disponibles.
'Error 3932 '%1 n’est pas un nom de domaine ou de groupe de travail valide.
'Error 3935 'La valeur SNTP actuelle est  '%1
'Error 3936 'Cet ordinateur n’est pas actuellement configuré pour utiliser un serveur SNTP spécifique.
'Error 3937 'Actuellement, cette valeur SNTP autoconfigurée est  '%1
'Error 3950 'Émettez à nouveau l’opération donnée en tant qu’opération E/S mise en cache.
'Error 3951 'Vous avez spécifié trop de valeurs pour l’option %1.
'Error 3952 'Vous avez spécifié une valeur non valide pour l’option %1.
'Error 3953 'La syntaxe est incorrecte.
'Error 3960 'Vous avez spécifié un numéro de fichier non valide.
'Error 3961 'Vous avez spécifié un numéro de travail d’impression non valide.
'Error 3963 'Le compte d’utilisateur ou le groupe spécifié est introuvable.
'Error 3965 'L’utilisateur a été ajouté mais n’a pas pu être activé pour les services de fichiers et d’impression pour NetWare.
'Error 3966 'Les services de fichiers et d’impression pour NetWare ne sont pas installés.
'Error 3967 'Impossible de mettre les propriétés de l’utilisateur pour les services de fichiers et d’impression pour NetWare.
'Error 3968 'Le mot de passe pour %1 est  '%2
'Error 3969 'Ouverture d’une session compatible NetWare.
'Error 4000 'WINS a rencontré une erreur alors qu’il exécutait la commande.
'Error 4001 'Le WINS local ne peut pas être supprimé.
'Error 4002 'L’importation à partir du fichier a échoué.
'Error 4003 'La sauvegarde a échoué. Une sauvegarde complète a-t-elle été effectuée avant celle-ci ?
'Error 4004 'La sauvegarde a échoué. Vérifiez le répertoire dans lequel vous êtes en train de sauvegarder la base de données.
'Error 4005 'Le nom n’existe pas dans la base de données WINS.
'Error 4006 'La réplication avec un partenaire non configuré n’est pas autorisée.
'Error 4050 'La version des informations fournies sur le contenu n’est pas prise en charge.
'Error 4051 'Les informations fournies sur le contenu ne sont pas correctement formées.
'Error 4052 'Impossible de trouver les données demandées dans les caches locaux ou d’homologue.
'Error 4053 'Aucune autre donnée n’est disponible ou requise.
'Error 4054 'L’objet fourni n’a pas été initialisé.
'Error 4055 'L’objet fourni a déjà été initialisé.
'Error 4056 'Une opération d’arrêt est déjà en cours.
'Error 4057 'L’objet fourni a déjà été invalidé.
'Error 4058 'Un élément existe déjà et n’a pas été remplacé.
'Error 4059 'Impossible d’annuler l’opération demandée, car elle a déjà été effectuée.
'Error 4060 'Impossible d’effectuer l’opération demandée, car elle a déjà été exécutée.
'Error 4061 'Une opération a accédé aux données au-delà des limites des données valides.
'Error 4062 'La version demandée n’est pas prise en charge.
'Error 4063 'Une valeur de configuration n’est pas valide.
'Error 4064 'La référence (SKU) n’est pas concédée sous licence.
'Error 4065 'Le service PeerDist est toujours en cours d’initialisation et sera disponible sous peu.
'Error 4066 'La communication avec un ou plusieurs ordinateurs va être bloquée temporairement en raison d’erreurs récentes.
'Error 4100 'Le client DHCP a obtenu une adresse IP qui est déjà utilisée sur le réseau. L’interface locale sera désactivée jusqu’à ce que le client DHCP puisse obtenir une nouvelle adresse.
'Error 4200 'L’identificateur GUID passé n’a pas été reconnu valide par un fournisseur de données WMI.
'Error 4201 'Le nom d’instance passé n’a pas été reconnu valide par un fournisseur de données WMI.
'Error 4202 'L’identificateur d’élément de données n’a pas été reconnu valide par un fournisseur de données WMI.
'Error 4203 'La requête WMI n’a pas pu être terminée et devrait être recommencée.
'Error 4204 'Le fournisseur de données WMI n’a pas pu être trouvé.
'Error 4205 'Le fournisseur de données WMI référence un jeu d’instances qui n’a pas été inscrit.
'Error 4206 'Le bloc de données WMI ou avertissement d’événement a déjà été activé.
'Error 4207 'Le bloc de données WMI n’est plus disponible.
'Error 4208 'Le service de données WMI n’est pas disponible.
'Error 4209 'Le fournisseur de données WMI n’a pas pu mener à bien la requête.
'Error 4210 'Les informations MOF de WMI ne sont pas valides.
'Error 4211 'Les informations d’inscription WMI ne sont pas valides.
'Error 4212 'Le bloc de données WMI ou l’avertissement d’événement ont déjà été désactivés.
'Error 4213 'L’élément de données ou le bloc de données WMI est en lecture seule.
'Error 4214 'L’élément de données ou le bloc de données WMI n’a pas pu être modifié.
'Error 4250 'Cette opération est valide uniquement dans le contexte d’un conteneur d’application.
'Error 4251 'Cette application ne peut être exécutée que dans le contexte d’un conteneur d’application.
'Error 4252 'Cette fonctionnalité n’est pas prise en charge dans le contexte d’un conteneur d’application.
'Error 4253 'La longueur du SID spécifiée n’est pas une longueur valide pour les SID de conteneur d’application.
'Error 4300 'L’identificateur de média ne représente pas un média valide.
'Error 4301 'L’identificateur de bibliothèque ne représente pas une bibliothèque valide.
'Error 4302 'L’identificateur de pool de média ne représente pas un pool de média valide.
'Error 4303 'Le lecteur et le média ne sont pas compatibles ou existent dans différentes bibliothèques.
'Error 4304 'Le média existe actuellement dans une bibliothèque déconnectée qui doit être connectée pour effectuer cette opération.
'Error 4305 'L’opération ne peut pas être effectuée sur une bibliothèque déconnectée.
'Error 4306 'La bibliothèque, le lecteur ou le pool de média sont vides.
'Error 4307 'La bibliothèque, le lecteur ou le pool de média doivent être vides pour effectuer cette opération.
'Error 4308 'Aucun média n’est actuellement disponible dans ce pool de média ou cette bibliothèque.
'Error 4309 'Une ressource requise pour cette opération est désactivée.
'Error 4310 'L’identificateur de média ne représente pas une cartouche de nettoyage valide.
'Error 4311 'Le lecteur ne peut pas être nettoyé ou ne prend pas en charge le nettoyage.
'Error 4312 'L’identificateur d’objet ne représente pas un objet valide.
'Error 4313 'Impossible de lire ou d’écrire dans la base de données.
'Error 4314 'Le base de données est pleine.
'Error 4315 'Le média n’est pas compatible avec le périphérique ou le pool de média.
'Error 4316 'La ressource requise pour cette opération n’existe pas.
'Error 4317 'L’identificateur d’opération n’est pas valide.
'Error 4318 'Le média n’est pas monté ou n’est pas prêt à être utilisé.
'Error 4319 'Le périphérique n’est pas prêt à être utilisé.
'Error 4320 'L’opérateur ou l’administrateur a refusé la requête.
'Error 4321 'L’identificateur de lecteur ne représente pas un lecteur valide.
'Error 4322 'La bibliothèque est pleine. Aucun emplacement n’est disponible.
'Error 4323 'Le transport ne peut pas accéder au média.
'Error 4324 'Impossible de charger le média dans le lecteur.
'Error 4325 'Impossible de récupérer l’état du lecteur.
'Error 4326 'Impossible de récupérer l’état de l’emplacement.
'Error 4327 'Impossible de récupérer l’état du transport.
'Error 4328 'Impossible d’utiliser le transport car il est déjà en cours d’utilisation.
'Error 4329 'Impossible d’ouvrir ou de fermer le port d’insertion / d’éjection.
'Error 4330 'Impossible d’éjecter le média car il est dans un lecteur.
'Error 4331 'Un emplacement de cartouche de nettoyage est déjà réservé.
'Error 4332 'Aucun emplacement de cartouche de nettoyage n’est réservé.
'Error 4333 'La cartouche de nettoyage a effectué le nombre maximal de nettoyages de lecteur.
'Error 4334 'Identificateur sur-média inattendu.
'Error 4335 'Le dernier élément de ce groupe ou de cette ressource n’a pas pu être supprimé.
'Error 4336 'Le message fourni dépasse la taille maximale autorisée pour ce paramètre.
'Error 4337 'Le volume contient des fichiers système ou des fichiers d’échange.
'Error 4338 'Impossible de supprimer le type de média de sa bibliothèque car au moins un lecteur dans la bibliothèque indique qu’il prend en charge ce type de média.
'Error 4339 'Il est impossible de monter ce média hors connexion car il n’y a aucun lecteur activé utilisable.
'Error 4340 'Une cartouche de nettoyage est présente dans le système d’archive sur bande automatisé.
'Error 4341 'Impossible d’utiliser le port d’injection/éjection car il n’est pas vide.
'Error 4342 'erreur
'Error 4343 'ok
'Error 4344 'O
'Error 4345 'n
'Error 4346 'Un (E)
'Error 4347 'a
'Error 4348 'P
'Error 4349 '(introuvable)
'Error 4350 'Ce fichier n’est pas utilisable sur cet ordinateur actuellement.
'Error 4351 'Le service de stockage étendu n’est actuellement pas opérationnel.
'Error 4352 'Le service de stockage étendu a rencontré une erreur de média.
'Error 4353 'Read
'Error 4354 'Change
'Error 4355 'Full
'Error 4356 'Veuillez entrer le mot de passe :
'Error 4357 'Entrez le mot de passe pour %1 :
'Error 4358 'Entrez un mot de passe pour l’utilisateur :
'Error 4359 'Entrez le mot de passe pour la ressource partagée :
'Error 4360 'Entrez votre mot de passe :
'Error 4361 'Entrez à nouveau le mot de passe pour confirmer :
'Error 4362 'Entrez l’ancien mot de passe de l’utilisateur :
'Error 4363 'Entrez le nouveau mot de passe de l’utilisateur :
'Error 4364 'Entrez votre nouveau mot de passe :
'Error 4365 'Entrez le mot de passe du service Duplicateur :
'Error 4366 'Entrez votre nom d’utilisateur ou appuyez sur ENTRÉE s’il s’agit de %1 :
'Error 4367 'Entrez le nom du domaine ou du serveur sur lequel vous voulez changer de mot de passe, ou appuyez sur ENTRÉE s’il s’agit du domaine %1 :
'Error 4368 'Entrez votre nom d’utilisateur :
'Error 4369 'Statistiques réseau de \\%1
'Error 4370 'Options d’impression de %1
'Error 4371 'Files d’attente de communication desservant %1
'Error 4372 'Informations sur un travail d’impression
'Error 4373 'Files d’attente de communication de \\%1
'Error 4374 'Imprimantes de %1
'Error 4375 'Imprimantes desservant %1
'Error 4376 'Travaux d’impression sur %1 :
'Error 4377 'Ressources partagées de %1
'Error 4378 'Les services exécutés suivants sont configurables :
'Error 4379 'Des statistiques sont disponibles pour les services exécutés suivants :
'Error 4380 'comptes d’utilisateurs de \\%1
'Error 4381 'La syntaxe de cette commande est :
'Error 4382 'Les options de cette commande sont :
'Error 4383 'Veuillez entrer le nom du contrôleur principal de domaine :
'Error 4384 'Vous avez entré une chaîne trop longue. La longueur maximale est %1. Recommencez, s.v.p.
'Error 4385 'Dimanche
'Error 4386 'Lundi
'Error 4387 'Mardi
'Error 4388 'Mercredi
'Error 4389 'Jeudi
'Error 4390 'Le fichier ou répertoire n’est pas un point d’analyse.
'Error 4391 'L’attribut de point d’analyse ne peut pas être défini car il est en conflit avec un attribut existant.
'Error 4392 'Les données présentes dans le tampon du point d’analyse ne sont pas valides.
'Error 4393 'L’étiquette présente dans le tampon du point d’analyse n’est pas valide.
'Error 4394 'La balise spécifiée dans la requête et celle présente dans le point d'analyse ne correspondent pas.
'Error 4395 'Le gestionnaire d'objets a rencontré un point d'analyse lors de la récupération d'un objet.
'Error 4396 'J
'Error 4397 'V
'Error 4398 's
'Error 4399 'SA
'Error 4400 'Données du Cache rapide introuvables.
'Error 4401 'Données du Cache rapide arrivées à expiration.
'Error 4402 'Données du Cache rapide endommagées.
'Error 4403 'Les données du Cache rapide ont dépassé leur taille maximale et ne peuvent pas être mises à jour.
'Error 4404 'Le Cache rapide a été réarmé et ne peut pas être mis à jour tant qu’il n’a pas été redémarré.
'Error 4405 'Alias de \\%1
'Error 4406 'Nom Alias
'Error 4407 'Commentaire
'Error 4408 'Membres
'Error 4410 'comptes d’utilisateurs de \\%1
'Error 4411 'Nom d’utilisateur
'Error 4412 'Nom complet
'Error 4413 'Commentaire
'Error 4414 'Commentaires UTILISATEUR
'Error 4415 'paramètres
'Error 4416 'Code du pays ou de la région
'Error 4417 'Niveau de privilège
'Error 4418 'Privilèges Opérateur
'Error 4419 'Compte  'Actif
'Error 4420 'Le démarrage sécurisé a détecté une tentative de restauration de données protégées.
'Error 4421 'La valeur est protégée par la stratégie de démarrage sécurisé, et ne peut pas être modifiée ou supprimée.
'Error 4422 'La stratégie de démarrage sécurisé n’est pas valide.
'Error 4423 'Une nouvelle stratégie de démarrage sécurisé ne comprenait pas l’éditeur actuel sur sa liste de mises à jour.
'Error 4424 'La stratégie de démarrage sécurisé n’est pas signée ou est signée par un signataire non approuvé.
'Error 4425 'Le démarrage sécurisé n’est pas activé sur cet ordinateur.
'Error 4426 'Le démarrage sécurisé nécessite que certains fichiers et pilotes ne soient pas remplacés par d’autres fichiers ou pilotes.
'Error 4427 'Le fichier de la stratégie de démarrage sécurisé supplémentaire n’a pas été autorisé sur cet ordinateur.
'Error 4428 'La stratégie supplémentaire n’est pas reconnue sur cet appareil.
'Error 4429 'Nous n’avons pas pu trouver la version Antirollback dans la stratégie de démarrage sécurisé.
'Error 4430 'L’ID de plateforme spécifié dans la stratégie de démarrage sécurisé ne correspond pas à l’ID de plateforme sur cet appareil.
'Error 4431 'Le fichier de la stratégie de démarrage sécurisé présente une version Antirollback antérieure à cet appareil.
'Error 4432 'Le fichier de la stratégie de démarrage sécurisé ne correspond pas à la stratégie héritée mise à niveau.
'Error 4433 'Le fichier de stratégie de démarrage sécurisé est requis, mais est introuvable.
'Error 4434 'Le fichier de stratégie de démarrage sécurisé supplémentaire ne peut pas être chargé en tant que stratégie de démarrage sécurisé de base.
'Error 4435 'Le fichier de stratégie de démarrage sécurisé de base ne peut pas être chargé en tant que stratégie de démarrage sécurisé supplémentaire.
'Error 4436 'Répertoire de base
'Error 4437 'Mot de passe exigé
'Error 4438 'L’utilisateur peut changer de mot de passe
'Error 4439 'profil d’utilisateur
'Error 4440 'L’opération de lecture de déchargement de copie n’est pas prise en charge par un filtre.
'Error 4441 'L’opération d’écriture de déchargement de copie n’est pas prise en charge par un filtre.
'Error 4442 'L’opération de lecture de déchargement de copie n’est pas prise en charge pour le fichier.
'Error 4443 'L’opération d’écriture de déchargement de copie n’est pas prise en charge pour le fichier.
'Error 4444 'Ce fichier est actuellement associé avec un id de flux différent.
'Error 4445 'Le volume doit subir un nettoyage de la mémoire.
'Error 4450 'Nom de l’ordinateur
'Error 4451 'Nom d’utilisateur
'Error 4452 'Version du logiciel
'Error 4453 'Station active sur
'Error 4454 'Racine Windows NT
'Error 4455 'Domaine de station
'Error 4456 'Domaine de connexion
'Error 4457 'Autre(s) domaine(s)
'Error 4458 'Délai d’ouverture COM (s)
'Error 4459 'Compteur d’émission COM (octets)
'Error 4460 'Délai d’émission COM (ms)
'Error 4461 'Délai d’impression des sessions DOS (s)
'Error 4462 'Taille max. du journal des erreurs (Ko)
'Error 4463 'Taille max. du cache (Ko)
'Error 4464 'Nombre de tampons réseau
'Error 4465 'Nombre de tampons caractère
'Error 4466 'Taille de tampon réseau
'Error 4467 'Taille de tampon caractère
'Error 4468 'Nom complet de l’ordinateur
'Error 4469 'Nom DNS du domaine de la station de travail
'Error 4470 'Windows 2002
'Error 4481 'Nom du serveur
'Error 4482 'Commentaires du serveur
'Error 4483 'Envoyer des alertes administratives à
'Error 4484 'Version du logiciel
'Error 4485 'serveur Homologue
'Error 4486 'Windows NT
'Error 4487 'niveau serveur
'Error 4488 'Serveur Windows NT
'Error 4489 'Serveur actif sur
'Error 4492 'serveur caché
'Error 4500 'Le stockage d’instance simple (SIS) n’est pas disponible sur ce volume.
'Error 4506 'Max. de sessions ouvertes
'Error 4507 'Max.d’administrateurs simultanés
'Error 4508 'Max. de ressources partagées
'Error 4509 'Nb max. de connexions aux ressources
'Error 4510 'Max. de fichiers ouverts sur serveur
'Error 4511 'Max. de fichiers ouverts par session
'Error 4512 'Max. de verrous de fichier
'Error 4520 'Durée d’inactivité de session (min)
'Error 4526 'ressource
'Error 4527 'UTILISATEUR
'Error 4530 'Serveur sans limite utilisateurs
'Error 4550 'L 'intégrité du système a détecté une tentative de restauration de la stratégie.
'Error 4551 'Votre organisation a utilisé Device Guard pour bloquer cette application. Contactez la personne chargée du support technique pour plus d’informations.
'Error 4552 'La stratégie d'intégrité du système n'est pas valide.
'Error 4553 'La stratégie d'intégrité du système n'est pas signée ou est signée par un signataire non approuvé.
'Error 4560 'Le mode sécurisé virtuel (VSM) n'est pas initialisé. L'hyperviseur ou le VSM ne sont peut-être pas présents ni activés.
'Error 4561 'L 'hyperviseur ne protège pas DMA, car une unité IOMMU n'est pas présente ni activée dans le BIOS.
'Error 4570 'Le fichier de manifeste de la plateforme n’a pas été autorisé sur cet ordinateur.
'Error 4571 'Le fichier de manifeste de la plateforme n’était pas valide.
'Error 4572 'Le fichier n’est pas autorisé sur cette plateforme, car nous n’avons pas pu trouver d’entrée dans le manifeste de la plateforme.
'Error 4573 'Le catalogue n’est pas autorisé sur cette plateforme, car nous n’avons pas pu trouver d’entrée dans le manifeste de la plateforme.
'Error 4574 'Le fichier n’est pas autorisé sur cette plateforme, car nous n’avons pas pu trouver d’ID binaire dans la signature incorporée.
'Error 4575 'Aucun manifeste de la plateforme n’est actif sur ce système.
'Error 4576 'Le fichier de manifeste de la plateforme n’a pas été correctement signé.
'Error 4577 'Contrôleur principal du domaine de la station de travail :
'Error 4578 'Seuil de verrouillage :
'Error 4579 'Durée du verrouillage (min) :
'Error 4580 'Fenêtre d’observation du verrouillage (min) :
'Error 4600 'Statistiques depuis
'Error 4601 'sessions acceptées
'Error 4602 'Déconnexions automatiques
'Error 4603 'Déconnexions sur erreur
'Error 4604 'Kilo-octets envoyés
'Error 4605 'Kilo-octets reçus
'Error 4606 'Temps de réponse moyen (ms)
'Error 4607 'Erreurs réseau
'Error 4608 'fichiers utilisés
'Error 4609 'Travaux d’impression mis en file d’attente
'Error 4610 'Erreurs système
'Error 4611 'Violations de mot de passe
'Error 4612 'Violations d’autorisation
'Error 4613 'Périphériques Comm.utilisés
'Error 4614 'sessions ouvertes
'Error 4615 'sessions reconnectées
'Error 4616 'Échecs de mises en route
'Error 4617 'sessions déconnectées
'Error 4618 'E/S réseau accomplies
'Error 4619 'Fichiers et canaux utilisés
'Error 4620 'Saturation des zones tampon
'Error 4621 'de grande taille
'Error 4622 'de demande
'Error 4623 'Statistiques de station de \\%1
'Error 4624 'Statistiques de serveur de \\%1
'Error 4625 'Statistiques depuis %1
'Error 4626 'Connexions établies
'Error 4627 'Échecs de connexion
'Error 4630 'Octets reçus
'Error 4631 'Blocs SMB reçus
'Error 4632 'Octets envoyés
'Error 4633 'Blocs SMB envoyés
'Error 4634 'lectures
'Error 4635 'Écritures
'Error 4636 'Refus de lectures brutes
'Error 4637 'Refus d’écritures brutes
'Error 4638 'Erreurs réseau
'Error 4639 'Connexions établies
'Error 4640 'Reconnexions
'Error 4641 'Déconnexions automatiques
'Error 4642 'sessions ouvertes
'Error 4643 'sessions bloquées
'Error 4644 'Échecs de sessions
'Error 4645 'Échecs d’opérations
'Error 4646 'Nb.d’utilisations
'Error 4647 'Nb.d’échecs d’utilisation
'Error 4650 '%1 a été supprimé.
'Error 4651 '%1 a été utilisé.
'Error 4652 'Le message a été envoyé à %1.
'Error 4653 'Les messages adressés à %1 sont maintenant transmis de manière appropriée.
'Error 4654 'L’alias %1 a été ajouté.
'Error 4655 'Fin de la transmission des messages.
'Error 4656 '%1 a été partagé.
'Error 4657 'Le serveur %1 a ouvert votre session sous le nom %2.
'Error 4658 'La session de %1 a été refermée.
'Error 4659 '%1 a été supprimé dans la liste des ressources partagées que le serveur crée au démarrage.
'Error 4661 'Le mot de passe a été changé correctement.
'Error 4662 '%1 fichier(s) copié(s).
'Error 4663 '%1 fichier(s) déplacé(s).
'Error 4664 'Le message a été envoyé à tous les utilisateurs du réseau.
'Error 4665 'Le message a été envoyé au domaine %1.
'Error 4666 'Le message a été envoyé à tous les utilisateurs de ce serveur.
'Error 4667 'Le message a été envoyé au groupe *%1.
'Error 4695 'Microsoft LAN Manager Version %1
'Error 4696 'Windows NT Server
'Error 4697 'Windows NT Workstation
'Error 4698 'Station de travail MS-DOS étendue
'Error 4699 'Créé à %1
'Error 4700 'Nom de serveur         Remarque
'Error 4701 'Impossible d’énumérer les serveurs dans les compartiments qui ne sont pas ceux par défaut.
'Error 4702 '(UNC)
'Error 4703 '...
'Error 4704 'domaine
'Error 4705 'Ressources sur %1
'Error 4706 'Fournisseur de réseau non valide. Les réseaux disponibles sont :
'Error 4710 'disque
'Error 4711 'Impr.
'Error 4712 'Comm.
'Error 4713 'IPC
'Error 4714 'État         Local     Distant                   Réseau
'Error 4715 'ok
'Error 4716 'Dormante
'Error 4717 'en Pause
'Error 4718 'déconnectée
'Error 4719 'erreur
'Error 4720 'Connexion en cours
'Error 4721 'Reconnexion en cours
'Error 4722 'état
'Error 4723 'Nom local
'Error 4724 'Nom distant
'Error 4725 'Type de ressource
'Error 4726 'ouvertures
'Error 4727 'Connexions
'Error 4728 'non disponible
'Error 4730 'Nom partage  Ressource                       Remarque
'Error 4731 'Nom du partage
'Error 4732 'ressource
'Error 4733 'Mis en file d’attente
'Error 4734 'Autorisation
'Error 4735 'Max. Utils.
'Error 4736 'Pas de limite
'Error 4737 'Utilisateurs
'Error 4738 'Le nom de partage entré n’est pas accessible à partir de stations MS-DOS. Voulez-vous vraiment utiliser ce nom de partage ? %1 :
'Error 4739 'Mise en cache
'Error 4740 'Nº fichier Chemin                                  Utilisateur     Verrous
'Error 4741 'Numéro de fichier
'Error 4742 'Verrous
'Error 4743 'Autorisations
'Error 4744 'Nom du partage
'Error 4745 'Type
'Error 4746 'utilisé Comme
'Error 4747 'Commentaire
'Error 4750 'Ordinateur             Nom d’utilisateur    Type de client   Ouv.  Inactivité
'Error 4751 'ordinateur
'Error 4752 'durée d’ouverture
'Error 4753 'durée d’inactivité
'Error 4754 'Nom du partage Type     Ouvertures
'Error 4755 'Type de client
'Error 4756 'session invité
'Error 4770 'Mise en cache manuelle des documents
'Error 4771 'Mise en cache automatique des documents
'Error 4772 'Mise en cache automatique des programmes et des documents
'Error 4773 'Mise en cache manuelle de documents avec BranchCache activée
'Error 4774 'Mise en cache désactivée
'Error 4775 'Automatic
'Error 4776 'Manual
'Error 4777 'Documents
'Error 4778 'Programs
'Error 4779 'BranchCache
'Error 4780 'None
'Error 4800 'Nom
'Error 4801 'Transmis vers
'Error 4802 'Transmis à vous-même par
'Error 4803 'Utilisateurs de ce serveur
'Error 4804 'Net Send a été interrompue par l’utilisateur (Ctrl+Pause).
'Error 4810 'Nom                     Travail nº    Taille            État
'Error 4811 'trav.
'Error 4812 'Impr.
'Error 4813 'Nom
'Error 4814 'travail nº
'Error 4815 'taille
'Error 4816 'état
'Error 4817 'fichier séparateur
'Error 4818 'Commentaire
'Error 4819 'Priorité
'Error 4820 'Imprimer après
'Error 4821 'Imprimer jusqu’à
'Error 4822 'Processeur d’impression
'Error 4823 'Infos supplémentaires
'Error 4824 'paramètres
'Error 4825 'Périphériques d’impression
'Error 4826 'Actif
'Error 4827 'Suspendu
'Error 4828 'Erreur sur l’imprimante
'Error 4829 'Suppression imminente
'Error 4830 'inconnu
'Error 4840 'Suspendu jusqu’à %1
'Error 4841 'travail nº
'Error 4842 'Propriétaire
'Error 4843 'Notifier
'Error 4844 'Type de données du travail
'Error 4845 'Paramètres du travail
'Error 4846 'en attente
'Error 4847 'Suspendu
'Error 4848 'Mise en file d’attente
'Error 4849 'en Pause
'Error 4850 'Hors connexion
'Error 4851 'erreur
'Error 4852 'Défaut de papier
'Error 4853 'Intervention nécessaire
'Error 4854 'Impression en cours
'Error 4855 'sur
'Error 4856 'Pause sur %1
'Error 4857 'Mode autonome sur %1
'Error 4858 'Erreur sur %1
'Error 4859 'Défaut de papier sur %1
'Error 4860 'Vérifier imprimante sur %1
'Error 4861 'Impression sur %1
'Error 4862 'pilote
'Error 4930 'Nom d’utilisateur      Type                 Date/Heure
'Error 4931 'Verrouillage
'Error 4932 'Service
'Error 4933 'serveur
'Error 4934 'serveur lancé
'Error 4935 'Pause du serveur
'Error 4936 'Reprise du serveur
'Error 4937 'serveur arrêté
'Error 4938 'session
'Error 4939 'session invité
'Error 4940 'session UTILISATEUR
'Error 4941 'session administrateur
'Error 4942 'Fin de session
'Error 4943 'Ouverture de session
'Error 4944 'Erreur lors de la fermeture de session
'Error 4945 'Session déconnectée automatiquement
'Error 4946 'Session déconnectée par l’administrateur
'Error 4947 'Session déconnectée par restriction d’accès
'Error 4948 'Service
'Error 4949 '%1 installé
'Error 4950 'Installation imminente de %1
'Error 4951 'Pause de %1
'Error 4952 'Pause imminente de %1
'Error 4953 'Reprise de %1
'Error 4954 'Reprise imminente de %1
'Error 4955 'Arrêt de %1
'Error 4956 'Arrêt imminent de %1
'Error 4957 'compte
'Error 4958 'Le compte d’utilisateur %1 a été modifié.
'Error 4959 'Le groupe %1 a été modifié.
'Error 4960 'Le compte d’utilisateur %1 a été supprimé
'Error 4961 'Le groupe %1 a été supprimé
'Error 4962 'Le compte d’utilisateur %1 a été ajouté
'Error 4963 'Le groupe %1 a été ajouté
'Error 4964 'Des paramètres du système de comptes ont été modifiés
'Error 4965 'Restriction d’accès
'Error 4966 'Limite dépassée  ' inconnue
'Error 4967 'Limite dépassée  ' Heures d’accès
'Error 4968 'Limite dépassée  ' compte expiré
'Error 4969 'Limite dépassée  ' Nom de station non valide
'Error 4970 'Limite dépassée  ' compte désactivé
'Error 4971 'Limite dépassée  ' compte supprimé
'Error 4972 'partage
'Error 4973 'Utilisation de %1
'Error 4974 'Fin d’utilisation de %1
'Error 4975 'Session utilisateur déconnectée %1
'Error 4976 'L’administrateur a mis fin au partage de %1
'Error 4977 'Limite d’utilisateurs atteinte pour %1
'Error 4978 'Mot de passe incorrect
'Error 4979 'Privilège administrateur requis
'Error 4980 'Accès
'Error 4981 '%1  'autorisations ajoutées
'Error 4982 '%1  'autorisations modifiées
'Error 4983 '%1  'autorisations supprimées
'Error 4984 'Accès refusé
'Error 4985 'inconnu
'Error 4986 'autre
'Error 4987 'Durée :
'Error 4988 'Durée  'non disponible
'Error 4989 'Durée  'moins d’une seconde
'Error 4990 '(aucune)
'Error 4991 'Fermeture de %1
'Error 4992 'Fermeture de %1 (déconnectée)
'Error 4993 'Fermeture de %1 par l’administrateur
'Error 4994 'Fin d’accès
'Error 4995 'Ouverture de session
'Error 4996 'Accès refusé
'Error 4997 'Programme       Message             Date/heure
'Error 4998 'Compte verrouillé en raison de la saisie de %1 mots de passe incorrects
'Error 4999 'Compte déverrouillé par l’administrateur
'Error 5000 'Fermeture session
'Error 5001 'Impossible de terminer l’opération car d’autres ressources dépendent de cette ressource.
'Error 5002 'La dépendance de la ressource de cluster ne peut pas être trouvée.
'Error 5003 'Une dépendance sur la ressource spécifiée ne peut pas être effectuée car la ressource de cluster est déjà dépendante.
'Error 5004 'Le ressource de cluster n’est pas connecté.
'Error 5005 'Un nœud de cluster n’est pas disponible pour cette opération.
'Error 5006 'La ressource de cluster n’est pas disponible.
'Error 5007 'La ressource de cluster n’a pas pu être trouvée.
'Error 5008 'Le cluster est en cours de fermeture.
'Error 5009 'Un nœud de cluster ne peut pas être expulsé du cluster à moins que le noeud ne soit tombé ou que ce soit le dernier nœud.
'Error 5010 'L’objet existe déjà.
'Error 5011 'L’objet est déjà dans la liste.
'Error 5012 'Le groupe de cluster n’est pas disponible pour de nouvelles requêtes.
'Error 5013 'Le groupe de cluster n’a pas pu être trouvé.
'Error 5014 'L’opération n’a pas pu se terminer car le groupe de cluster n’est pas connecté.
'Error 5015 'L’opération a échoué car le nœud de cluster spécifié n’est pas le propriétaire de la ressource ou le nœud n’est pas un propriétaire possible de la ressource.
'Error 5016 'L’opération a échoué car le nœud de cluster spécifié n’est pas le propriétaire du groupe ou le nœud n’est pas un propriétaire possible du groupe.
'Error 5017 'La ressource de cluster n’a pas pu être créée dans le moniteur de ressources spécifié.
'Error 5018 'Le moniteur de ressources n’a pas pu connecter la ressource de cluster.
'Error 5019 'L’opération n’a pas pu se terminer car la ressource de cluster est connectée.
'Error 5020 'La ressource de cluster n’a pas pu être supprimée ou déconnectée car elle est la ressource de quorum.
'Error 5021 'Le cluster n’a pas pu faire de la ressource spécifiée une ressource de quorum car elle ne peut pas être une ressource de quorum.
'Error 5022 'Le logiciel du cluster est en cours de fermeture.
'Error 5023 'Le groupe ou la ressource n’est pas dans l’état correct pour effectuer l’opération requise.
'Error 5024 'Les propriétés étaient enregistrées mais toutes les modifications ne prendront effet qu’à la prochaine connexion de la ressource.
'Error 5025 'Le cluster n’a pas pu faire de la ressource spécifiée une ressource de quorum car elle n’appartient pas à une classe de stockage partagée.
'Error 5026 'La ressource de cluster n’a pas pu être supprimée car elle est une ressource essentielle.
'Error 5027 'La ressource de quorum n’a pas pu se connecter.
'Error 5028 'Le journal de quorum n’a pas pu être créé ou monté.
'Error 5029 'Le journal de cluster est endommagé.
'Error 5030 'L’enregistrement n’a pas pu être écrit dans le journal de clusters car il dépasse la taille maximale.
'Error 5031 'Le journal de clusters dépasse sa taille maximale.
'Error 5032 'Aucun enregistrement de point de contrôle n’a été trouvé dans le journal de clusters.
'Error 5033 'L’espace disque minimal nécessaire pour l’enregistrement n’est pas disponible.
'Error 5034 'Le nœud de cluster n’a pas pu prendre le contrôle de la ressource de quorum car la ressource est détenue par un autre nœud actif.
'Error 5035 'Aucun réseau de clusters n’est disponible pour cette opération.
'Error 5036 'Un nœud de cluster n’est pas disponible pour cette opération.
'Error 5037 'Tous les nœuds du cluster doivent être actifs pour effectuer cette opération.
'Error 5038 'Une ressource du cluster a échoué.
'Error 5039 'Ce nœud de cluster n’est pas valide.
'Error 5040 'Ce nœud de cluster existe déjà.
'Error 5041 'Un nœud est en train de rejoindre le cluster.
'Error 5042 'Le nœud du cluster n’a pas été trouvé.
'Error 5043 'Les informations sur le nœud local du cluster sont introuvables.
'Error 5044 'Le réseau de clusters existe déjà.
'Error 5045 'Le réseau de clusters est introuvable.
'Error 5046 'L’interface réseau de clusters existe déjà.
'Error 5047 'L’interface réseau de clusters est introuvable.
'Error 5048 'La requête du cluster n’est pas valide pour cet objet.
'Error 5049 'Le fournisseur réseau de clusters n’est pas valide.
'Error 5050 'Le nœud du cluster est inactif.
'Error 5051 'Le nœud du cluster n’est pas joignable.
'Error 5052 'Le nœud n’est pas membre du cluster.
'Error 5053 'Aucune opération de jonction du cluster n’est en cours.
'Error 5054 'Le réseau de clusters n’est pas valide.
'Error 5055 'Mar
'Error 5056 'Le nœud du cluster est actif.
'Error 5057 'L’adresse IP du cluster est déjà en cours d’utilisation.
'Error 5058 'Le nœud du cluster n’est pas interrompu.
'Error 5059 'Aucun contexte de sécurité de cluster n’est disponible.
'Error 5060 'Le réseau de clusters n’est pas configuré pour la communication interne des clusters.
'Error 5061 'Le nœud du cluster est déjà actif.
'Error 5062 'Le nœud du cluster est déjà inactif.
'Error 5063 'Le réseau de clusters est déjà en ligne.
'Error 5064 'Le réseau de clusters est déjà hors connexion.
'Error 5065 'Le nœud du cluster est déjà membre du cluster.
'Error 5066 'Le réseau de clusters est le seul configuré pour la communication interne des clusters entre les nœuds de clusters actifs. La capacité de communication interne ne peut pas être supprimée sur le réseau.
'Error 5067 'Au moins une ressource du cluster dépend du réseau pour pouvoir fournir un service aux clients. La capacité d’accès client ne peut pas être supprimée du réseau.
'Error 5068 'Impossible d’effectuer cette action pour le moment sur le groupe de clusters qui contient la ressource quorum.
'Error 5069 'La ressource quorum du cluster n’est pas autorisée à avoir des dépendances.
'Error 5070 'Le nœud du cluster est en pause.
'Error 5071 'La ressource du cluster ne peut pas être mise en ligne. Le nœud propriétaire ne peut pas exécuter cette ressource.
'Error 5072 'Le nœud du cluster n’est pas prêt à exécuter l’opération demandée.
'Error 5073 'Arrêt du nœud du cluster en cours.
'Error 5074 'L’opération de jonction du cluster a été arrêtée.
'Error 5075 'Le noeud n'a pas pu joindre le cluster en raison de l'incompatibilité entre sa version de système d'exploitation et celle des autres noeuds. Pour plus d'informations sur les versions de système d'exploitation du cluster, exécutez l'Assistant Validation d'une c
'Error 5076 'Cette ressource ne peut pas être créée car le cluster a atteint le nombre maximal de ressources qu’il peut analyser.
'Error 5077 'La configuration système a été modifiée lors de l’opération de jonction ou de formation de cluster. Cette opération a été interrompue.
'Error 5078 'Impossible de trouver le type de ressource spécifié.
'Error 5079 'Le nœud spécifié ne prend pas en charge une ressource de ce type. Ceci peut être dû à des incohérences entre versions ou à l’absence de la DLL de ressources sur ce nœud.
'Error 5080 'Le nom de ressource spécifié n’est pas pris en charge par cette DLL de ressources. Ceci peut être dû à un nom incorrect (ou modifié) fourni à la DLL de ressources.
'Error 5081 'Aucun package d’authentification n’a pu être inscrit avec le serveur RPC.
'Error 5082 'Il est impossible de connecter le groupe car le propriétaire du groupe ne se trouve pas dans la liste de préférence du groupe. Pour changer le nœud propriétaire pour le groupe, déplacez le groupe.
'Error 5083 'Échec de l’opération de jonction  'le numéro de séquence de base de données de cluster a été modifié ou est incompatible avec le nœud de verrouillage. Ceci peut arriver lors d’une opération de jonction si la base de données de cluster est modifiée au moment de
'Error 5084 'Le moniteur de ressources ne permettra pas que l’opération qui a échoué soit effectuée tant que la ressource sera dans l’état actuel. Ceci peut se produire quand la ressource est dans un état provisoire.
'Error 5085 'Un code, qui n’est pas un code de verrouillage, a reçu une requête pour réserver le verrouillage pour des mises à jour globales.
'Error 5086 'Le disque quorum n’a pas pu être trouvé par le service de cluster.
'Error 5087 'Il est possible que la base de données de clusters sauvegardée soit endommagée.
'Error 5088 'Une racine DFS existe déjà dans ce nœud de cluster.
'Error 5089 'Une tentative de modification d’une propriété de ressource a échoué à cause d’un conflit avec une propriété existante.
'Error 5090 'Cette opération n’est pas prise en charge sur un cluster sans point d’accès administratif.
'Error 5091 'Danemark
'Error 5092 'Suède
'Error 5093 'Norvège
'Error 5094 'Allemagne
'Error 5095 'Australie
'Error 5096 'Japon
'Error 5097 'Corée
'Error 5098 'Chine (RPC)
'Error 5099 'Taïwan
'Error 5100 'Asie
'Error 5101 'Portugal
'Error 5102 'Finlande
'Error 5103 'Arabe
'Error 5104 'Hébreu
'Error 5150 'Une panne de courant a eu lieu sur %1. Mettez fin à toutes les activités faisant appel à ce serveur.
'Error 5151 'Le courant a été rétabli sur %1. L’exécution du service Serveur a été reprise.
'Error 5152 'Le service Onduleur commence la procédure d’arrêt de %1.
'Error 5153 'Le service Onduleur commence la procédure d’arrêt finale.
'Error 5170 'Il faut lancer la station de travail avec la commande NET START.
'Error 5175 'IPC distant
'Error 5176 'Administration à distance
'Error 5177 'Partage par défaut
'Error 5178 'Profils UTILISATEUR
'Error 5280 'Le mot de passe entré fait plus de 14 caractères. Les ordinateurs  dont la version de Windows est antérieure à Windows 2000 ne pourront pas utiliser  ce compte. Voulez-vous continuer cette opération ? %1:
'Error 5281 '%1 a mémorisé la connexion à %2. Souhaitez-vous recouvrir la connexion mémorisée ? %3 :
'Error 5282 'Voulez-vous continuer le chargement du profil ? La commande ayant provoqué l’erreur sera ignorée. %1 :
'Error 5284 'Voulez-vous continuer cette opération ? %1 :
'Error 5285 'Désirez-vous faire cet ajout ? %1 :
'Error 5286 'Voulez-vous continuer cette opération ? %1 :
'Error 5287 'D’accord pour le lancer ? %1 :
'Error 5288 'Désirez-vous lancer le service Station de travail ? %1 :
'Error 5289 'D’accord pour continuer la déconnexion et forcer les fermetures ? %1 :
'Error 5290 'L’imprimante n’existe pas. Désirez-vous la créer ? %1 :
'Error 5291 'Jamais
'Error 5292 'Jamais
'Error 5293 'Jamais
'Error 5295 'NET.HLP
'Error 5296 'NET.HLP
'Error 5297 'Refuser
'Error 5300 'La demande NCB a été satisfaite. Le NCB est fourni dans les données.
'Error 5301 'Longueur de tampon NCB non autorisée dans SEND DATAGRAM, SEND BROADCAST, ADAPTER STATUS ou SESSION STATUS. Le NCB est fourni dans les données.
'Error 5302 'Le tableau descripteur de données spécifié dans le NCB n’est pas valide. Le NCB est fourni dans les données.
'Error 5303 'La commande spécifiée dans le NCB n’est pas autorisée. Le NCB est fourni dans les données.
'Error 5304 'Le corrélateur de messages spécifié dans le NCB n’est pas valide. Le NCB est fourni dans les données.
'Error 5305 'Une commande NCB a dépassé un délai d’attente. La session a peut-être subi une fermeture anormale. Le NCB est fourni dans les données.
'Error 5306 'Un message NCB incomplet a été reçu. Le NCB est fourni dans les données.
'Error 5307 'L’adresse de zone tampon spécifiée dans le NCB n’est pas autorisée. Le NCB est fourni dans les données.
'Error 5308 'Le numéro de session spécifié dans le NCB n’est pas actif. Le NCB est fourni dans les données.
'Error 5309 'Aucune ressource n’était disponible dans la carte réseau. La demande NCB a été rejetée. Le NCB est fourni dans les données.
'Error 5310 'La session spécifiée dans le NCB a été refermée. Le NCB est fourni dans les données.
'Error 5311 'La commande NCB a été annulée. Le NCB est fourni dans les données.
'Error 5312 'Le segment message spécifié dans le NCB est illogique. Le NCB est fourni dans les données.
'Error 5313 'Le nom existe déjà dans la table de nom de carte locale. La demande NCB a été rejetée. Le NCB est fourni dans les données.
'Error 5314 'La table des noms de cartes réseau est saturée. La demande NCB a été rejetée. Le NCB est fourni dans les données.
'Error 5315 'Le réseau nommé possède des sessions actives et ne figure plus en mémoire. L’exécution de la commande NCB est terminée. Le NCB est fourni dans les données.
'Error 5316 'Une commande Receive Lookahead émise antérieurement est active pour cette session. La commande NCB a été rejetée. Le NCB est fourni dans les données.
'Error 5317 'La table de sessions locale est saturée. La demande NCB a été rejetée. Le NCB est fourni dans les données.
'Error 5318 'Une ouverture de session NCB a été rejetée. Il n’y a pas de LISTEN en instance sur l’ordinateur distant. Le NCB est fourni dans les données.
'Error 5319 'Le numéro de nom spécifié dans le NCB n’est pas autorisé. Le NCB est fourni dans les données.
'Error 5320 'Le nom d’appel spécifié dans le NCB est introuvable ou ne répond pas. Le NCB est fourni dans les données.
'Error 5321 'Le nom spécifié dans le NCB est introuvable. Impossible de placer '*' ou 00h dans le nom de NCB. Le NCB est fourni dans les données.
'Error 5322 'Le nom spécifié dans le NCB est déjà utilisé sur une carte distante. Le NCB est fourni dans les données.
'Error 5323 'Le nom spécifié dans le bloc de contrôle réseau (NCB) a été supprimé. Le NCB est fourni dans les données.
'Error 5324 'La session spécifiée dans le NCB s’est arrêtée de manière anormale. Le NCB est fourni dans les données.
'Error 5325 'Le protocole réseau a détecté plusieurs noms identiques sur le réseau.  Le NCB est fourni dans les données.
'Error 5326 'Réception d’un paquet de protocole inattendu. Il y a peut-être un périphérique distant incompatible. Le NCB est fourni dans les données.
'Error 5333 'L’interface NetBios est occupée. La demande NCB a été rejetée. Le NCB est fourni dans les données.
'Error 5334 'Il y a trop de commandes NCB en instance. La demande NCB a été rejetée. Le NCB est fourni dans les données.
'Error 5335 'Le numéro de carte spécifié dans le NCB n’est pas autorisé. Le NCB est fourni dans les données.
'Error 5336 'L’exécution de la commande NCB se terminait lorsqu’une annulation s’est produite. Le NCB est fourni dans les données.
'Error 5337 'Le nom spécifié dans le NBC est réservé. Le NCB est fourni dans les données.
'Error 5338 'Il n’est pas possible d’annuler la commande NCB. Le NCB est fourni dans les données.
'Error 5351 'Il y a plusieurs demandes NCB pour la même session. La demande NCB a été rejetée. Le NCB est fourni dans les données.
'Error 5352 'Une erreur de carte réseau s’est produite. La seule commande NETBIOS possible est NCB RESET. Le NCB est fourni dans les données.
'Error 5354 'Dépassement du nombre maximal d’applications. La demande NCB a été rejetée. Le NCB est fourni dans les données.
'Error 5356 'Les ressources demandées ne sont pas disponibles. La demande NCB a été rejetée. Le NCB est fourni dans les données.
'Error 5364 'Une erreur système s’est produite. La demande NCB a été rejetée. Le NCB est fourni dans les données.
'Error 5365 'Une erreur de total de contrôle ROM s’est produite. La demande NCB a été rejetée. Le NCB est fourni dans les données.
'Error 5366 'Une erreur de Test RAM s’est produite. La demande NCB a été rejetée. Le NCB est fourni dans les données.
'Error 5367 'Une erreur de bouclage numérique s’est produite. La demande NCB a été rejetée. Le NCB est fourni dans les données.
'Error 5368 'Une erreur de bouclage analogique s’est produite. La demande NCB a été rejetée. Le NCB est fourni dans les données.
'Error 5369 'Une erreur due à l’interface s’est produite. La demande NCB a été rejetée. Le NCB est fourni dans les données.
'Error 5370 'Réception d’un code de retour NCB inconnu. Le NCB est fourni dans les données.
'Error 5380 'Défaillance au niveau de la carte réseau. La demande NCB a été rejetée. Le NCB est fourni dans les données.
'Error 5381 'La commande NCB est toujours en instance. Le NCB est fourni dans les données.
'Error 5500 'Le journal de mise à jour sur %1 est saturé à 80%%. Le contrôleur de domaine principal %2 ne retrouve pas les mises à jour.
'Error 5501 'Le journal de mise à jour sur %1 est saturé, et aucune mise à jour ultérieure ne pourra s’y ajouter jusqu’à ce que le contrôleur de domaine principal %2 retrouve les mises à jour.
'Error 5502 'La différence de temps avec le contrôleur principal de domaine %1 dépasse le maximum fixé à %2 secondes.
'Error 5503 'Le compte de l’utilisateur %1 a été verrouillé sur %2 à la suite de %3 tentatives de violation de mot de passe.
'Error 5504 'Impossible d’ouvrir le fichier journal %1.
'Error 5505 'Le fichier journal %1 est endommagé et va être effacé.
'Error 5506 'Le fichier journal des applications n’a pas pu être ouvert. %1 sera utilisé en tant que fichier journal par défaut.
'Error 5507 'Le fichier journal %1 est plein. Si ce message apparaît pour la première fois, effectuez les actions suivantes 
' 1. Cliquez sur Démarrer, cliquez sur Exécuter, entrez "eventvwr", puis cliquez sur OK.
' 2. Cliquez sur %1, cliquez sur le menu Action, cliquez su
'Error 5508 'La synchronisation complète de la base de données de la sécurité a été déclenchée par le serveur %1.
'Error 5509 'Windows n’a pas pu démarrer comme configuré. Une configuration précédente qui fonctionne a été utilisée à la place.
'Error 5510 'L’exception 0x%1 s’est produite dans l’application %2 à l’emplacement 0x%3.
'Error 5511 'Les serveurs %1 et %3 prétendent tous deux être contrôleur de domaine du domaine %2. L’un d’eux devrait être supprimé du domaine car ils ont des identificateurs de sécurité (SID) différents.
'Error 5512 'Les serveurs %1 et %2 prétendent tous deux être contrôleur principal de domaine pour le domaine %3. Un des serveurs devrait être rétrogradé ou enlevé du domaine.
'Error 5513 'L’ordinateur %1 a tenté de se connecter au serveur %2 en utilisant la relation d’approbation établie par le domaine %3. Cependant, l’ordinateur a perdu l’identificateur de sécurité (SID) correct lorsque le domaine a été reconfiguré. Vous devez rétablir la rela
'Error 5514 'L’ordinateur a redémarré à partir d’une vérification d’erreur. La vérification d’erreur était  '%1. %2 Un vidage complet n’a pas été enregistré.
'Error 5515 'L’ordinateur a redémarré à partir d’une vérification d’erreur. La vérification d’erreur était  '%1. %2 Un vidage a été enregistré dans  '%3.
'Error 5516 'L’ordinateur ou le domaine %1 approuve le domaine %2. (Ceci est peut-être une approbation indirecte). Cependant, %1 et %2 ont le même identifiant de sécurité ordinateur (SID). NT devrait être réinstallé soit sur %1 soit sur %2.
'Error 5517 'L’ordinateur ou le domaine %1 approuve le domaine %2. (Ceci est peut-être une approbation indirecte). Cependant, %2 n’est pas un nom de domaine de confiance valide. Le nom du domaine de confiance devrait être modifié pour être valide.
'Error 5600 'Impossible de partager le chemin Utilisateur ou Script.
'Error 5601 'Le mot de passe pour cet ordinateur est introuvable dans la base de données de la sécurité locale.
'Error 5602 'Une erreur interne s’est produite lors d’un accès à la base de données de la sécurité locale ou réseau de l’ordinateur.
'Error 5700 'Le service Accès réseau n’a pas pu initialiser les structures de données de la réplication. Le service a été arrêté. L’erreur suivante s’est produite :
'%1
'Error 5701 'Le service Accès réseau n’a pas pu mettre à jour la liste d’approbation de domaines. L’erreur suivante s’est produite :
'%1
'Error 5702 'Le service Accès réseau n’a pas pu ajouter l’interface RPC. Le service a été arrêté. L’erreur suivante s’est produite :
'%1
'Error 5703 'Le service Accès réseau n’a pas pu lire un message de boîte aux lettres envoyé par %1 en raison de l’erreur suivante :
'%2
'Error 5704 'Le service Accès réseau n’a pas pu inscrire le service avec le contrôleur de services. Le service a été arrêté. L’erreur suivante s’est produite :
'%1
'Error 5705 'Le cache de journal des modifications conservé par le service Accès réseau pour les modifications de base de données %1 est incohérent. Le service Accès réseau réinitialise le journal des modifications.
'Error 5706 'Le service Accès réseau n’a pas pu créer la ressource partagée de serveur %1. L’erreur suivante s’est produite :
'%2
'Error 5707 'Échec de la demande d’accès de bas niveau pour l’utilisateur %1 de %2.
'Error 5708 'Échec de la demande de déconnexion de bas niveau pour l’utilisateur %1 de %2.
'Error 5709 'Échec de la demande d’accès Windows NT ou Windows 2000 %1 pour l’utilisateur %2\%3 de %4 (via %5).
'Error 5710 'Échec de la demande de déconnexion Windows NT ou Windows 2000 %1 pour l’utilisateur  %2\%3 de %4.
'Error 5711 'La demande de synchronisation partielle émise par le serveur %1 a été satisfaite. %2 modification(s) retourné(s) à l’appelant.
'Error 5712 'Échec de la demande de synchronisation partielle émise par le serveur %1 avec l’erreur suivante :
'%2
'Error 5713 'La demande de synchronisation complète émise par le serveur %1 a été satisfaite. %2 objet(s) retourné(s) à l’appelant.
'Error 5714 'Échec de la demande de synchronisation complète émise par le serveur %1 avec l’erreur suivante :
'%2
'Error 5715 'La réplication de synchronisation partielle de la base de données %1 depuis le contrôleur principal de domaine %2 s’est terminée correctement. %3 modification(s) appliquée(s) à la base de données.
'Error 5716 'Échec de la réplication de synchronisation partielle de la base de données %1 depuis le contrôleur principal de domaine %2 avec l’erreur suivante :
'%3
'Error 5717 'La réplication de synchronisation complète de la base de données %1 depuis le contrôleur principal de domaine %2 s’est terminée correctement.
'Error 5718 'La réplication de synchronisation complète de la base de données %1 depuis le contrôleur principal de domaine %2 a échoué avec l’erreur suivante :
'%3
'Error 5720 'La configuration de session du contrôleur de domaine Windows %1 du domaine %2 a échoué car l'ordinateur %3 n'a pas de compte dans la base de données de sécurité locale.
'Error 5722 'Échec de l’authentification de la configuration de session de l’ordinateur %1. Le nom du compte référencé dans la base de données de la sécurité est %2. L’erreur suivante s’est produite :
'%3
'Error 5724 'Impossible d’inscrire le gestionnaire de contrôle avec le contrôleur de services %1.
'Error 5725 'Impossible de définir l’état de service avec le contrôleur de services %1.
'Error 5726 'Le nom d’ordinateur %1 est introuvable.
'Error 5727 'Impossible de charger le pilote de périphérique %1.
'Error 5728 'Impossible de charger un transport.
'Error 5729 'La réplication de l’objet Domaine %1 "%2" à partir du contrôleur principal du domaine %3 a échoué avec l’erreur suivante :
'%4
'Error 5730 'La réplication du Groupe global %1 "%2" à partir du contrôleur principal du domaine %3 a échoué avec l’erreur suivante :
'%4
'Error 5731 'La réplication du Groupe local %1 "%2" à partir du contrôleur principal du domaine %3 a échoué avec l’erreur suivante :
'%4
'Error 5732 'La réplication de l’Utilisateur %1 "%2" à partir du contrôleur principal du domaine %3 a échoué avec l’erreur suivante :
'%4
'Error 5733 'La réplication de l’objet Stratégie %1 "%2" à partir du contrôleur principal du domaine %3 a échoué avec l’erreur suivante :
'%4
'Error 5734 'La réplication de l’objet Domaine approuvé %1 "%2" à partir du contrôleur principal du domaine %3 a échoué avec l’erreur suivante :
'%4
'Error 5735 'La réplication de l’objet Compte %1 "%2" à partir du contrôleur principal du domaine %3 a échoué avec l’erreur suivante :
'%4
'Error 5736 'La réplication du Secret %1 "%2" à partir du contrôleur principal du domaine %3 a échoué avec l’erreur suivante :
'%4
'Error 5737 'Le système a renvoyé le code d’erreur inattendu suivant :
'%1
'Error 5738 'Netlogon a détecté deux comptes ordinateur pour le serveur "%1". Le serveur peut être soit un serveur Windows 2000 Server qui est un membre du domaine soit un serveur LAN Manager avec un compte dans le groupe global SERVEURS. Il ne peut pas être les deux à la
'Error 5739 'Ce domaine possède plus de groupes globaux qu’il n’est possible d’en répliquer vers un contrôleur de domaine secondaire Lanman. Soit vous effacez certains de vos groupes globaux soit vous supprimez les contrôleurs de domaine secondaires Lanman du domaine.
'Error 5740 'Le pilote de l’explorateur a renvoyé l’erreur suivante à l’accès réseau :
'%1
'Error 5741 'Netlogon n’a pas pu enregistrer le nom %1<1B> pour la raison suivante :
'%2
'Error 5742 'Le service n’a pas pu retrouver les messages nécessaires à l’amorçage des clients à téléamorçage.
'Error 5743 'Le service a rencontré une erreur grave et ne peut plus fournir le téléamorçage pour les clients 3Com à téléamorçage 3Start.
'Error 5744 'Le service a rencontré une erreur système grave et va s’arrêter tout seul.
'Error 5745 'Le client avec le nom d’ordinateur %1 n’a pas pu accuser réception des données d’amorçage. Le téléamorçage de ce client n’a pas été terminé.
'Error 5746 'Le client avec le nom d’ordinateur %1 n’a pas été amorcé du fait d’une erreur lors de l’ouverture du fichier %2.
'Error 5747 'Le client avec le nom d’ordinateur %1 n’a pas été amorcé du fait d’une erreur lors de la lecture du fichier %2.
'Error 5748 'Le client avec le nom d’ordinateur %1 n’a pas été amorcé du fait du manque de mémoire du serveur de téléamorçage.
'Error 5749 'Le client avec le nom d’ordinateur %1 sera amorcé sans utiliser de totaux de contrôle car le total de contrôle pour le fichier %2 n’a pas pu être calculé.
'Error 5750 'Le client avec le nom d’ordinateur %1 n’a pas été amorcé du fait du trop grand nombre de lignes dans le fichier %2.
'Error 5751 'Le client avec le nom d’ordinateur %1 n’a pas été amorcé car le fichier de configuration de bloc d’amorçage %2 pour ce client ne contient pas de ligne de bloc d’amorçage et/ou de ligne de chargement.
'Error 5752 'Le client avec le nom d’ordinateur %1 n’a pas été amorcé du fait de la taille erronée du fichier %2.
'Error 5753 'Le client avec le nom d’ordinateur %1 n’a pas été amorcé du fait d’une erreur interne du service de téléamorçage.
'Error 5754 'Le client avec le nom d’ordinateur %1 n’a pas été amorcé car le fichier %2 possède un en-tête d’amorçage non valide.
'Error 5755 'Le client avec le nom d’ordinateur %1 n’a pas été amorcé du fait d’une erreur réseau.
'Error 5756 'Le client avec l’ID de carte %1 n’a pas été amorcé du fait du manque de ressources.
'Error 5757 'Le service a rencontré une erreur lors de la copie du fichier ou du répertoire %1.
'Error 5758 'Le service a rencontré une erreur lors de la suppression du fichier ou du répertoire %1.
'Error 5759 'Le service a rencontré une erreur lors du paramétrage des autorisations sur le fichier ou le répertoire %1.
'Error 5760 'Le service a rencontré une erreur lors de l’évaluation des configurations RPL.
'Error 5761 'Le service a rencontré une erreur lors de la création des profils RPL pour toutes les configurations.
'Error 5762 'Le service a rencontré une erreur lors de l’accès au registre.
'Error 5763 'Le service a rencontré une erreur lors du remplacement du fichier probablement trop ancien RPLDISK.SYS.
'Error 5764 'Le service a rencontré une erreur lors de l’ajout des comptes de sécurité ou en  paramétrant les autorisations de fichier. Ces comptes sont le groupe local RPLUSER et les comptes d’utilisateurs pour les stations de travail RPL individuelles.
'Error 5765 'Le service a échoué au cours de la sauvegarde de sa base de données.
'Error 5766 'Le service n’a pas pu s’initialiser depuis sa base de données. La base de données est peut être absente ou endommagée. Le service va essayer de restaurer la base de données. depuis la sauvegarde.
'Error 5767 'Le service n’a pas pu restaurer sa base de données depuis la sauvegarde. Le service ne démarrera pas.
'Error 5768 'Le service a restauré sa base de données depuis la sauvegarde.
'Error 5769 'Le service n’a pas pu s’initialiser depuis sa base de données restaurée. Le service ne démarrera pas.
'Error 5771 'La base de données de téléamorçage est au format NT 3.5 ou NT 3.51 et Windows NT est en train d’essayer de la convertir au format NT 4.0. Le convertisseur JETCONV écrira un événement dans le journal des événements des applications lorsque ce sera terminé.
'Error 5772 'Le groupe global SERVERS existe dans le domaine %1 et possède des membres. Ce groupe définit les contrôleurs de domaine secondaires LAN Manager dans le domaine. Les contrôleurs de domaine secondaires LAN Manager ne sont pas autorisés dans les domaines NT.
'Error 5773 'Le serveur DNS suivant qui fait autorité pour les enregistrements de contrôleur de domaine DNS de ce contrôleur de domaine ne prend pas en charge les mises à jour DNS dynamiques :
'
'Adresse IP du serveur DNS  '%1
'Code de réponse renvoyé (RCODE)  '%2
'Cod
'Error 5776 'Impossible de créer/d’ouvrir le fichier %1 avec l’erreur suivante :
'%2
'Error 5777 'Netlogon a reçu l’erreur suivante lors de la tentative d’obtention des informations de correspondance du sous-réseau au site à partir de l’annuaire :
'%1
'Error 5778 ''%1' a tenté de déterminer son site en recherchant son adresse IP ('%2') dans Configuration\Sites\Conteneur de sous-réseau dans le DS. Aucun sous-réseau correspond à l’adresse IP. Essayez d’ajouter un objet sous-réseau pour cette adresse IP.
'Error 5779 'Le nom de site pour cet ordinateur est '%1'. Ce nom de site n’est pas un nom de site valide. Un nom de site doit être un nom DNS valide. Renommez le site avec un nom valide.
'Error 5780 'L’objet de sous-réseau '%1' apparaît dans le conteneur Configuration\Sites\Sous-réseau de l’annuaire. La syntaxe du nom est incorrecte. La syntaxe est xx.xx.xx.xx/yy où xx.xx.xx.xx est un numéro de sous-réseau IP valide et yy est le nombre de bits dans le masq
'Error 5782 'L’enregistrement ou la suppression de l’enregistrement dynamique d’un ou plusieurs enregistrements DNS a échoué avec l’erreur suivante :
'%1
'Error 5783 'La session définie pour le contrôleur de domaine %1 pour le domaine %2 ne répond pas. L'appel RPC en cours de Netlogon sur \\%3 à %1 a été annulé.
'Error 5784 'Le site '%2' n’a pas de contrôleur de domaine pour le domaine '%3'. Les contrôleurs de domaine dans le site '%1' ont été automatiquement sélectionnés pour couvrir le site '%2' pour le domaine '%3' basé sur les coûts de réplication du serveur de répertoires con
'Error 5785 'Ce contrôleur de domaine ne couvre plus automatiquement le site '%1'pour le domaine '%2'.
'Error 5786 'Le site '%2' n’a pas de serveur de catalogue global pour la forêt '%3'. Les serveurs de catalogue global dans le site '%1' ont été sélectionnés automatiquement pour couvrir le site '%2' pour la forêt '%3' basé sur les coûts de réplication des serveurs de réper
'Error 5787 'Ce serveur de catalogues globaux ne couvre plus automatiquement le site '%1' pour la forêt '%2'.
'Error 5788 'La tentative de mise à jour des noms de principal du service (SPN) HOST de l’objet ordinateur dans Active Directory a échoué. Les valeurs mises à jour étaient '%1' et '%2'. L’erreur suivante s’est produite :
'%3
'Error 5789 'La tentative de mise à jour du nom d’hôte DNS de l’ordinateur  dans Active Directory a échoué. La valeur mise à jour était '%1'. L’erreur suivante s’est produite :
'%2
'Error 5790 'Aucun contrôleur de domaine adéquat n’est disponible pour le domaine %1. Un contrôleur de domaine NT4 ou antérieur est disponible mais ne peut pas être utilisé pour des besoins d’authentification dans un domaine Windows 2000 ou un domaine plus récent dont l’or
'Error 5791 'Le domaine de cet ordinateur, %1 a été rétrogradé de Windows 2000 ou un domaine plus récent à un domaine Windows NT4 ou antérieur. L’ordinateur ne peut pas fonctionner correctement dans ce cas pour des besoins d’authentification. Cet ordinateur doit rejoindre
'Error 5792 'Le site '%2' n’a pas de serveurs LDAP pour des contextes de noms '%3' (qui n’appartiennent pas aux domaines). Les serveurs LDAP dans le site '%1' ont été sélectionné automatiquement pour couvrir le site '%2' pour des contextes de nom '%3' (qui n’appartiennent
'Error 5793 'Ce serveur LDAP ne couvre plus automatiquement le site '%1' pour des contextes de nom '%2' (qui n’appartiennent pas aux domaines).
'Error 5794 'Le site '%2' n’est plus configuré manuellement dans le Registre comme étant couvert par ce contrôleur de domaine pour le domaine '%3'. Par conséquent, le site '%2' n’a aucun contrôleurs de domaine pour le domaine '%3'. Les contrôleurs de domaine dans le site '
'Error 5795 'Ce contrôleur de domaine ne couvre plus automatiquement le site '%1' pour le domaine '%2'. Cependant, le site '%1' est toujours (manuellement) couvert par ce contrôleur de domaine pour le domaine '%2' puisque ce site a été manuellement configuré dans le Regist
'Error 5796 'Le site '%2' n’est plus automatiquement configuré dans le Registre par ce serveur de catalogue global pour la forêt '%3'. Par conséquent, le site '%2' n’a pas de serveurs de catalogue global pour la forêt '%3'. Les serveurs de catalogue global du site '%1' ont
'Error 5797 'Ce serveur de catalogue global ne couvre plus automatiquement le site '%1' pour la  forêt '%2'. Cependant, le site '%1' est toujours (manuellement) couvert par ce  catalogue global pour la forêt '%2' puisque ce site a été manuellement configuré dans le Registr
'Error 5799 'Ce serveur LDAP ne couvre plus automatiquement le site '%1' pour des contextes de nom '%2' (qui n’appartiennent pas aux domaines). Cependant le site '%1' est toujours couvert (manuellement) par ce serveur LDAP pour des contextes de nom '%2' (qui n’appartiennen
'Error 5800 'La tentative de mise à niveau des attributs de l’objet ordinateur de DnsHostName et de l’hôte de nom de principal du service (SPN) dans Active Directory a échoué car le nom du compte de l’ordinateur, '%2' n’a pas pu être mappé à l’objet ordinateur du contrôleu
'Error 5803 'L’erreur suivante s’est produite lors de la lecture d’un paramètre ’%2' dans la section Netlogon %1 du Registre :
'%3
'Error 5804 'La clé de Registre Netlogon %1 contient une valeur non valide 0x%2 pour le paramètre '%3'. Les valeurs minimales et maximales autorisées pour ce paramètre sont respectivement 0x%4 et 0x%5. La valeur 0x%6 a été assignée à ce paramètre.
'Error 5805 'L’installation de la session à partir de l’ordinateur %1 n’a pas pu être authentifiée. L’erreur suivante s’est produite :
'%2
'Error 5806 'Les mises à jour dynamiques DNS ont été désactivées manuellement sur ce contrôleur de domaine.
'
'Action UTILISATEUR
'Reconfigurer ce contrôleur de domaine pour utiliser les mises à jour DNS dynamiques ou ajouter manuellement les enregistrements DNS du fic
'Error 5808 'La suppression de l’enregistrement de certains enregistrements de contrôleur de domaine DNS a été annulé lors de la rétrogradation de ce contrôleur de domaine car les annulations d’enregistrement DNS prenaient trop de temps.
'
'Action UTILISATEUR
'Supprime
'Error 5813 'La demande d’inscription dynamique pour l’enregistrement DNS « %1 » a été refusée par le contrôleur de domaine distant « %2 ». Erreur  '« %3 »
'
'Afin que les ordinateurs et les utilisateurs trouvent ce contrôleur de domaine, cet enregistrement doit être ins
'Error 5814 'La demande de désinscription dynamique de l’enregistrement DNS « %1 » a été refusée par le contrôleur de domaine distant « %2 ». Erreur  '« %3 »
'
'Pour empêcher des ordinateurs distants de se connecter inutilement à ce contrôleur de domaine, un administrate
'Error 5816 'Netlogon a échoué à une demande d’authentification du compte %1 dans le domaine %2. La demande a expiré avant d’être  envoyée au contrôleur %3 dans le domaine %4. Il s’agit du premier échec. Si le problème se reproduit,  les événements consolidés seront consig
'Error 5817 'Netlogon a échoué à %1 autres demandes d’authentification au cours des dernières %2 minutes. Les demandes ont expiré avant qu’elles puissent être envoyées au contrôleur %3 dans le domaine %4. Pour plus d’informations, voir http://support.microsoft.com/kb/26540
'Error 5818 'Netlogon a nécessité plus de %1 secondes pour une demande d’authentification du compte %2 dans le domaine %3, à travers  le contrôleur %4 du domaine %5. Il s’agit du premier avertissement. Si le problème persiste, un événement périodique sera consigné  toutes
'Error 5819 'Netlogon a nécessité plus de %1 secondes pour %2 demandes d’authentification à travers le contrôleur %3 du domaine %4 au cours des %5 dernières minutes. Pour plus d’informations, voir http://support.microsoft.com/kb/2654097.
'Error 5820 'Le service Accès réseau n’a pas pu ajouter l’interface RPC AuthZ. Le service a été arrêté. L’erreur suivante s’est produite  '« %1 ».
'Error 5821 'Le service Accès réseau n’a pas pu initialiser le gestionnaire de ressources AuthZ. Le service a été arrêté. L’erreur suivante s’est produite  '« %1 ».
'Error 5822 'Le service Accès réseau n’a pas pu initialiser le descripteur de sécurité  de l’interface RPC du service Accès réseau. Le service a été arrêté. L’erreur  suivante s’est produite  '« %1 ».
'Error 5823 ' Le système a correctement changé de mot de passe sur le contrôleur  de domaine %1.  Cet événement est consigné dans le journal de l’ordinateur lorsque  le mot de passe est modifié par le système de l’ordinateur.
'Error 5824 ' Le système a correctement changé le mot de passe du compte  de service géré %1  sur le contrôleur de domaine %2.  Cet événement est consigné dans le journal de l’ordinateur  où il se produit pour un compte de service géré  autonome.
'Error 5890 'Une opération incompatible avec l’état actuel de l’adhésion au nœud a été tentée.
'Error 5891 'La ressource quorum ne contient pas le journal quorum.
'Error 5892 'Le moteur d’adhésion a demandé l’arrêt du service de cluster sur ce nœud.
'Error 5893 'L’opération de jonction a échoué car l’ID de l’instance du cluster du noeud à joindre ne correspond pas à l’ID de l’instance du cluster du noeud initial.
'Error 5894 'Le réseau de clusters correspondant à l’adresse IP spécifiée est introuvable.
'Error 5895 'Le type de données réel de la propriété ne correspond pas au type de données attendu de la propriété.
'Error 5896 'L’application n’a pas pu démarrer car sa configuration côte-à-côte est incorrecte. Pour plus d’informations, consultez le journal des événements des applications ou utilisez l’outil de ligne de commande sxstrace.exe.
'Error 5897 'Deux ou plusieurs valeurs de paramètres spécifiées pour les propriétés d’une ressource sont en conflit.
'Error 5898 'Cet ordinateur ne peut pas être membre d’un cluster.
'Error 5899 'Cet ordinateur ne peut pas être membre d’un cluster car la version installée de Windows n’est pas correcte.
'Error 5900 'Un cluster ne peut pas être créé avec le nom de cluster spécifié car ce nom de cluster est déjà utilisé. Spécifiez un autre nom de cluster.
'Error 5901 'L’action de configuration du cluster a déjà été allouée.
'Error 5902 'L’action de configuration du cluster n’a pas pu être annulée.
'Error 5903 'La lettre de lecteur assignée à un disque système sur un nœud est en conflit avec la lettre de lecteur assigné à un disque sur un autre nœud.
'Error 5904 'Un ou plusieurs noeuds du cluster exécutent une version de Windows qui ne prend pas en charge cette opération.
'Error 5905 'Le nom du compte d’ordinateur correspondant ne correspond pas au nom réseau pour cette ressource.
'Error 5906 'Aucune carte réseau n’est disponible.
'Error 5907 'Le nœud de cluster a été empoisonné.
'Error 5908 'Le groupe ne peut accepter la demande car il est en cours de déplacement vers un autre nœud.
'Error 5909 'Le type de ressource ne peut accepter la demande car il est trop occupé à effectuer une autre opération.
'Error 5910 'Le délai d’appel de la DLL de ressource de cluster est dépassé.
'Error 5911 'L’adresse n’est pas valide pour une ressource d’adresse IPv6. Une adresse IPv6 globale est requise, et elle doit correspondre à un réseau de clusters. Les adresses de compatibilité ne sont pas autorisées.
'Error 5912 'Une erreur de cluster interne s’est produite suite à un appel d’une fonction non valide.
'Error 5913 'Une valeur de paramètre se trouve en dehors de la plage autorisée.
'Error 5914 'Une erreur réseau s’est produite lors de l’envoi de données à un autre nœud du cluster. Le nombre d’octets transmis était inférieur au nombre requis.
'Error 5915 'Tentative d’opération sur le Registre de cluster non valide.
'Error 5916 'Une chaîne d’entrée de caractères n’a pas été terminée correctement.
'Error 5917 'Le format d’une chaîne d’entrée de caractères n’est pas valide pour les données représentées.
'Error 5918 'Erreur de cluster interne. Une transaction de base de données de cluster a été tentée alors qu’une transaction était déjà en cours.
'Error 5919 'Erreur de cluster interne. Tentative de validation d’une transaction de base de données de cluster alors qu’aucune transaction n’était en cours.
'Error 5920 'Erreur de cluster interne. Les données n’étaient pas correctement initialisées.
'Error 5921 'Une erreur s’est produite lors de la lecture à partir d’un flux de données. Un nombre d’octets inattendu a été retourné.
'Error 5922 'Une erreur s’est produite lors de l’écriture vers un flux de données. Impossible d’écrire le nombre d’octets requis.
'Error 5923 'Une erreur s’est produite lors de la désérialisation d’un flux de données de cluster.
'Error 5924 'Une ou plusieurs valeurs de propriété pour cette ressource sont en conflit avec une ou plusieurs valeurs de propriété associées à ses ressources dépendantes.
'Error 5925 'Aucun quorum de nœuds de cluster n’était présent pour former un cluster.
'Error 5926 'Le réseau de clusters n’est pas valide pour une ressource d’adresse IPv6 ou il ne correspond pas à l’adresse configurée.
'Error 5927 'Le réseau de clusters n’est pas valide pour une ressource de tunnel IPv6. Vérifiez la configuration de la ressource d’adresse IP dont dépend la ressource de tunnel IPv6.
'Error 5928 'La ressource de quorum ne peut pas résider dans le groupe de stockage disponible.
'Error 5929 'Les dépendances de la ressource sont imbriquées trop profondément.
'Error 5930 'L’appel de la DLL de la ressource a déclenché une exception inattendue.
'Error 5931 'L’initialisation du processus RHS a échoué.
'Error 5932 'La fonction Clustering avec basculement n’est pas installée sur ce nœud.
'Error 5933 'Les ressources doivent être en ligne sur le même nœud pour cette opération.
'Error 5934 'Impossible d’ajouter un nouveau nœud, car le nombre maximal de nœuds a déjà été atteint pour ce cluster.
'Error 5935 'Impossible de créer ce cluster, car le nombre de nœuds spécifié dépasse la limite maximale autorisée.
'Error 5936 'L’utilisation du nom de cluster spécifié a échoué, car un objet ordinateur activé portant le même nom existe déjà dans le domaine.
'Error 5937 'Impossible de détruire ce cluster. Il contient des groupes d’applications non noyau qui doivent être supprimés pour permettre la destruction du cluster.
'Error 5938 'Le partage de fichiers associé à la ressource témoin de partage de fichiers ne peut pas être hébergé par ce cluster ou l’un quelconque de ses nœuds.
'Error 5939 'La suppression de ce nœud n’est pas valide pour le moment. En raison des exigences de quorum, la suppression du nœud résulte en l’arrêt du cluster. S’il s’agit du dernier nœud du cluster, la commande Destroy cluster doit être utilisée.
'Error 5940 'Une seule instance de ce type de ressource est autorisée dans le cluster.
'Error 5941 'Une seule instance de ce type de ressource est autorisée par groupe de ressources.
'Error 5942 'La mise en ligne de la ressource a échoué en raison de la défaillance d’une ou plusieurs ressources de fournisseur.
'Error 5943 'La ressource a indiqué qu’elle ne peut être mise en ligne sur aucun nœud.
'Error 5944 'L’opération actuelle ne peut pas être exécutée sur ce groupe à l’heure actuelle.
'Error 5945 'Le répertoire ou le fichier ne se trouve pas sur un volume partagé du cluster.
'Error 5946 'Le descripteur de sécurité ne répond pas aux conditions requises pour un cluster.
'Error 5947 'Il existe une ou plusieurs ressources de volumes partagés dans le cluster. Ces ressources doivent être déplacées vers un stockage disponible pour que l’opération réussisse.
'Error 5948 'Ce groupe ou cette ressource ne peuvent pas être manipulés directement.  Utilisez les API de volume partagé pour effectuer l’opération souhaitée.
'Error 5949 'La sauvegarde est en cours. Attendez la fin de la sauvegarde avant de recommencer l’opération.
'Error 5950 'Ce chemin n’appartient pas à un volume partagé en clusters.
'Error 5951 'Le volume partagé en clusters n’est pas monté localement sur ce nœud.
'Error 5952 'La surveillance du cluster est en train de se terminer.
'Error 5953 'Une ressource a refusé un déplacement entre deux nœuds car ils sont incompatibles.
'Error 5954 'La demande n’est pas valide, car le poids du nœud ne peut pas être modifié lorsque le cluster est en mode de quorum de disque uniquement, ou lorsque la modification du poids du nœud ne respecte pas la configuration minimale du quorum de cluster.
'Error 5955 'La ressource a refusé l’appel.
'Error 5956 'Impossible de démarrer ou d’exécuter la ressource car elle ne pourrait pas réserver suffisamment de ressources système.
'Error 5957 'Une ressource a refusé un déplacement entre deux nœuds car la destination ne dispose actuellement pas de suffisamment de ressources pour effectuer l’opération.
'Error 5958 ' Une ressource a refusé un déplacement entre deux nœuds car la source ne dispose actuellement pas de suffisamment de ressources pour effectuer l’opération.
'Error 5959 ' Impossible d’effectuer l’opération demandée car le groupe est placé en file d’attente pour une opération.
'Error 5960 ' Impossible d’effectuer l’opération demandée car une ressource a le statut verrouillé.
'Error 5961 ' La ressource ne peut pas être déplacée vers un autre nœud car un volume partagé de cluster a refusé l’opération.
'Error 5962 ' Un drainage des nœuds est déjà en cours.
'Error 5963 ' Le stockage en cluster n’est pas connecté au nœud.
'Error 5964 ' Le disque n’est pas configuré pour être utilisé avec CSV. Les disques CSV doivent posséder au moins une partition au format NTFS OU REFS.
'Error 5965 ' La ressource doit faire partie du groupe Stockage disponible pour terminer cette action.
'Error 5966 ' Échec de l’opération CSVFS, car le volume est en mode redirigé.
'Error 5967 ' Échec de l’opération CSVFS, car le volume n’est pas en mode redirigé.
'Error 5968 ' Impossible de retourner les propriétés du cluster pour l’instant.
'Error 5969 ' La ressource de disque en cluster contient une zone diff de capture instantanée logicielle qui n’est pas prise en charge pour les volumes partagés de cluster.
'Error 5970 ' Impossible d’effectuer l’opération, car la ressource est en mode de maintenance.
'Error 5971 ' Impossible d’effectuer l’opération en raison de conflits d’affinité
'Error 5972 ' Impossible d’effectuer l’opération, car la ressource est un réplica d’ordinateur virtuel.
'Error 5973 ' Impossible d 'augmenter le niveau fonctionnel de cluster, car tous les noeuds du cluster ne prennent pas en charge la version mise à jour.
'Error 5974 ' Échec de la mise à jour du niveau fonctionnel de cluster, car le cluster est exécuté en mode de quorum fixe. Démarrez des noeuds supplémentaires membres du cluster jusqu'à ce que ce dernier atteigne le quorum et qu'il se déconnecte automatiquement du mode de
'Error 5975 ' Le niveau fonctionnel du cluster a été mis à jour, mais certaines fonctionnalités ne sont pas encore disponibles. Redémarrez le cluster en utilisant la cmdlet PowerShell Stop-Cluster suivie de la cmdlet PowerShell Start-Cluster. Toutes les fonctionnalités du
'Error 5976 ' Le cluster exécute actuellement une mise à niveau de la version.
'Error 5977 ' Le cluster n'a pas exécuté correctement la mise à niveau de la version.
'Error 5978 ' Le noeud de cluster est en période de grâce.
'Error 5979 ' Échec de l'opération, car le volume CSV n'a pas pu récupérer dans le délai imparti sur cet objet de fichier.
'Error 5980 ' Échec de l'opération, car le noeud demandé n'est pas actuellement un membre actif du cluster.
'Error 5981 ' Échec de l'opération, car la ressource de cluster demandée n'est pas actuellement contrôlée.
'Error 5982 ' Échec de l'opération, car l'une des ressources ne prend pas en charge l'exécution dans un état non contrôlé.
'Error 5983 ' Impossible de terminer l'opération, car l'une des ressources participe à la réplication.
'Error 5984 ' Échec de l'opération, car le noeud de cluster demandé a été isolé
'Error 5985 ' Échec de l'opération, car le noeud de cluster demandé a été mis en quarantaine
'Error 5986 ' Échec de l'opération, car la condition de mise à jour de base de données spécifiée n'a pas été remplie.
'Error 5987 ' Impossible d 'effectuer l'opération à ce stade, car un espace en cluster se trouve dans un état détérioré.
'Error 5988 ' Échec de l'opération, car la délégation de jeton pour ce contrôle n'est pas prise en charge.
'Error 5989 ' Échec de l'opération, car le volume partagé de cluster a invalidé cet objet fichier.
'Error 5990 ' Cette opération est prise en charge uniquement sur le noeud coordinateur du volume partagé de cluster.
'Error 5991 ' L’ensemble de groupes de clusters n’est pas disponible pour d’autres demandes.
'Error 5992 ' L’ensemble de groupes de clusters est introuvable.
'Error 5993 ' Cette action ne peut pas aboutir pour l’instant, car l’ensemble de groupes de clusters risque de passer sous le quorum et de ne pas pouvoir agir comme fournisseur.
'Error 5994 ' Le domaine d’erreur du parent spécifié est introuvable.
'Error 5995 ' Le domaine d’erreur ne peut pas être un enfant du parent spécifié.
'Error 5996 ' Les espaces de stockage direct ont rejeté les modifications du domaine d’erreur proposées, car elles ont des répercussions sur la tolérance de panne du stockage.
'Error 5997 ' Les espaces de stockage direct ont rejeté les modifications du domaine d’erreur proposées, car elles réduisent l’espace de stockage connecté au système.
'Error 5998 ' Impossible de créer le serveur de fichiers de l'infrastructure de cluster car aucun nom de serveur de fichiers non vide et valide n' été spécifié.
'Error 5999 ' Impossible de terminer cette action car le cluster de gestion de l'ensemble de clusters est inaccessible.
'Error 6000 'Le fichier spécifié n’a pas pu être chiffré.
'Error 6001 'Le fichier spécifié n’a pas pu être déchiffré.
'Error 6002 'Le fichier spécifié est chiffré et l’utilisateur n’a pas la capacité de le déchiffrer.
'Error 6003 'Aucune stratégie de récupération de chiffrement valide n’est configurée pour ce système.
'Error 6004 'Le pilote de chiffrement requis n’est pas chargé pour ce système.
'Error 6005 'Le fichier a été chiffré avec un pilote de chiffrement différent de celui qui est chargé.
'Error 6006 'Aucune clé EFS n’est définie pour l’utilisateur.
'Error 6007 'Le fichier spécifié n’est pas chiffré.
'Error 6008 'Le fichier spécifié n’est pas dans le format d’exportation EFS défini.
'Error 6009 'Le fichier spécifié est en lecture seulement.
'Error 6010 'Le répertoire a été désactivé pour chiffrement .
'Error 6011 'Le serveur n’est pas approuvé pour des opérations de chiffrement à distance.
'Error 6012 'La stratégie de récupération configurée pour ce système contient un certificat de récupération non valide.
'Error 6013 'L’algorithme de chiffrement utilisé sur le fichier source nécessite une mémoire tampon de clé plus importante que celle sur le fichier de destination.
'Error 6014 'La partition de disque ne prend pas en charge le chiffrement de fichiers.
'Error 6015 'Le chiffrement de fichiers est désactivé sur cet ordinateur.
'Error 6016 'Un nouveau système est nécessaire pour déchiffrer ce fichier chiffré.
'Error 6017 'Le serveur distant a envoyé une réponse non valide pour un fichier ouvert avec le Chiffrement côté client.
'Error 6018 'Le Chiffrement côté client n’est pas pris en charge par le serveur distant, même si ce dernier prétend le contraire.
'Error 6019 'Le fichier est chiffré et doit être ouvert en mode Chiffrement côté client.
'Error 6020 'Un nouveau fichier chiffré est en cours de création et un $EFS doit être fourni.
'Error 6021 'Le client SMB a demandé un CSE FSCTL sur un fichier non CSE.
'Error 6022 'L’opération demandée a été bloquée par la stratégie. Pour plus d’informations, contactez votre administrateur système.
'Error 6118 'La liste des serveurs de ce groupe de travail n’est pas disponible actuellement
'Error 6200 'Le service planificateur de tâches doit être configuré pour fonctionner sur le compte système pour fonctionner correctement. Des tâches individuelles peuvent être configurées pour fonctionner dans d’autres comptes.
'Error 6600 'Le service de journalisation a détecté un secteur de journal non valide.
'Error 6601 'Le service de journalisation a détecté un secteur de journal à la parité de bloc non valide.
'Error 6602 'Le service de journalisation a détecté un secteur de journal remappé.
'Error 6603 'Le service de journalisation a détecté un bloc de journal incomplet.
'Error 6604 'Le service de journalisation a détecté une tentative d’accès à des données normalement exclues du journal.
'Error 6605 'Les zones tampon de tri du service de journalisation sont pleines.
'Error 6606 'Le service de journalisation a détecté une tentative de lecture dans une zone de tri sans contexte de lecture valide.
'Error 6607 'Le service de journalisation a détecté une zone de reprise de journal non valide.
'Error 6608 'Le service de journalisation a détecté une version de bloc de journal non valide.
'Error 6609 'Le service de journalisation a détecté un bloc de journal non valide.
'Error 6610 'Le service de journalisation a détecté une tentative de lecture dans le journal en mode de lecture non valide.
'Error 6611 'Le service de journalisation a détecté un flux de journal sans zone de reprise.
'Error 6612 'Le service de journalisation a détecté un fichier de métadonnées endommagé.
'Error 6613 'Le service de journalisation a détecté un fichier de métadonnées qui n’a pas pu être crée par le système de fichiers hébergeant le journal.
'Error 6614 'Le service de journalisation a détecté un fichier de métadonnées comportant des incohérences.
'Error 6615 'Le service de journalisation a détecté un échec d’allocation ou de libération d’espace de réservation.
'Error 6616 'Le service de journalisation ne peut pas supprimer un fichier journal ou un conteneur de système de fichiers.
'Error 6617 'Le service de journalisation a atteint le nombre maximal de conteneurs admis pour un fichier journal.
'Error 6618 'Le service de journalisation a fait une tentative de lecture à un point précédant le début du journal.
'Error 6619 'L’installation de la stratégie de journalisation a échoué en raison de la présence d’une stratégie du même type.
'Error 6620 'La stratégie de journalisation en question n’a pas été installée au moment de la requête.
'Error 6621 'L’ensemble des stratégies installées associées au journal est invalide.
'Error 6622 'Une stratégie associée au journal en question a empêché l’accomplissement de l’opération.
'Error 6623 'Le journal ne peut pas être recyclé pour l’instant, car il est requis par le processus d’archivage.
'Error 6624 'L’entrée de journal ne vient pas de ce fichier journal.
'Error 6625 'Le nombre brut ou corrigé d’entrées de journal réservées n’est pas valide.
'Error 6626 'L’espace brut ou corrigé réservé pour le journal n’est pas valide.
'Error 6627 'Une base ou un processus d’archivage, nouveau ou existant, associé au journal actif n’est pas valide.
'Error 6628 'L’espace de journalisation arrive à saturation.
'Error 6629 'Impossible de définir le journal à la taille demandée.
'Error 6630 'Journal multiplexé, aucune écriture directe dans le journal physique n’est autorisée.
'Error 6631 'L’opération a échoué car le journal est un journal dédié.
'Error 6632 'Cette opération nécessite un contexte d’archivage.
'Error 6633 'L’archivage des journaux est en cours d’exécution.
'Error 6634 'Cette opération nécessite un journal non éphémère, mais ce journal est éphémère.
'Error 6635 'Le journal doit comporter au moins deux conteneurs pour pouvoir être lu ou modifié.
'Error 6636 'Un client de journal est déjà inscrit sur le flux.
'Error 6637 'Aucun client de journal n’est inscrit sur le flux.
'Error 6638 'Une demande a déjà été faite pour gérer l’erreur liée au journal saturé.
'Error 6639 'Le service de journalisation a rencontré une erreur lors de la lecture d’un conteneur journal.
'Error 6640 'Le service de journalisation a rencontré une erreur lors de l’écriture dans un conteneur journal.
'Error 6641 'Le service de journalisation a rencontré une erreur lors de l’ouverture d’un conteneur journal.
'Error 6642 'Le service de journalisation a détecté un état de conteneur non valide lors d’une opération demandée.
'Error 6643 'Le service de journalisation n’est pas dans un état lui permettant d’effectuer l’opération demandée.
'Error 6644 'L’espace occupé par le journal ne peut pas être recyclé du fait qu’il est en service.
'Error 6645 'Échec du vidage des métadonnées de journal.
'Error 6646 'La sécurité dans le journal et ses conteneurs n’est pas cohérente.
'Error 6647 'Des enregistrements ont été ajoutés au journal ou des modifications de réservation ont été effectuées, mais le journal n’a pas pu être vidé.
'Error 6648 'Le journal est épinglé car une réservation utilise la plupart de l’espace réservé au journal. Libérez des enregistrements réservés pour rendre plus d’espace disponible.
'Error 6700 'Le descripteur de transaction associé à cette opération n’est pas valide.
'Error 6701 'L’opération demandée a été réalisée dans le cadre d’une transaction qui n’est plus active.
'Error 6702 'L’opération demandée n’est pas valide sur l’objet Transaction dans son état actuel.
'Error 6703 'L’appelant a appelé une API de réponse, mais la réponse n’est pas attendue car le Gestionnaire de transactions n’a pas émis la demande correspondante à l’appelant.
'Error 6704 'Il est trop tard pour effectuer l’opération demandée car la transaction a déjà été annulée.
'Error 6705 'Il est trop tard pour effectuer l’opération demandée car la transaction a déjà été validée.
'Error 6706 'Le Gestionnaire de transactions n’a pas été initialisé. Les opérations traitées avec transaction ne sont pas prises en charge.
'Error 6707 'Le Gestionnaire de ressources spécifié n’a apporté aucune modification ou mise à jour à la ressource sous cette transaction.
'Error 6708 'Le Gestionnaire de ressources a tenté de préparer une transaction qu’il n’a pas pu joindre.
'Error 6709 'L’objet Transaction a déjà un enrôlement supérieur et l’appelant a tenté une opération qui en aurait créé un autre. Seul un enrôlement supérieur est autorisé.
'Error 6710 'Le Gestionnaire de ressources a tenté d’inscrire un protocole qui existe déjà.
'Error 6711 'Échec de la propagation de la transaction.
'Error 6712 'Le protocole de propagation demandé n’était pas inscrit en tant que CRM.
'Error 6713 'Le format du tampon passé à PushTransaction ou à PullTransaction n’est pas valide.
'Error 6714 'Le contexte de transaction actuel associé au thread n’est pas un descripteur valide d’un objet transaction.
'Error 6715 'L’objet Transaction spécifié n’a pas pu être ouvert car il est introuvable.
'Error 6716 'L’objet ResourceManager spécifié n’a pas pu être ouvert car il est introuvable.
'Error 6717 'L’objet Enlistment spécifié n’a pas pu être ouvert car il est introuvable.
'Error 6718 'L’objet TransactionManager spécifié n’a pas pu être ouvert car il est introuvable.
'Error 6719 'Impossible de créer ou d’ouvrir l’objet spécifié, car son TransactionManager associé n’est pas en ligne. TransactionManager doit être mis complètement en ligne en appelant RecoverTransactionManager à partir de son LogFile afin de permettre l’ouverture des obje
'Error 6720 'L’objet TransactionManager spécifié n’a pas pu créer dans l’espace de noms Objet les objets décrits dans son fichier journal. TransactionManager n’a donc pas pu être récupéré.
'Error 6721 'L’appel visant à créer une inscription supérieure sur cet objet Transaction n’a pas abouti car l’objet Transaction spécifié pour l’inscription est une branche subordonnée de l’objet Transaction. Seule la racine de l’objet Transaction peut être inscrite comme u
'Error 6722 'Comme le gestionnaire de transactions ou le gestionnaire de ressources associé a été fermé, le descripteur n’est plus valide.
'Error 6723 'L’opération spécifiée n’a pas pu être effectuée sur cet enrôlement supérieur car l’enrôlement n’a pas été créé avec la réponse de conclusion correspondante dans NotificationMask.
'Error 6724 'L’opération spécifiée n’a pas pu être effectuée car l’enregistrement à journaliser était trop long. Ceci peut se produire dans les deux cas suivants  'il y a trop d’inscriptions sur cette transaction ou les informations de récupération combinées journalisées d
'Error 6725 'Les transactions implicites ne sont pas prises en charge.
'Error 6726 'Le gestionnaire de transactions du noyau a dû annuler ou ignorer la transaction car il a bloqué la progression vers l’avant.
'Error 6727 'L’identité de TransactionManager fournie ne correspondait pas à celle qui a été enregistrée dans le fichier journal de TransactionManager.
'Error 6728 'Cette opération de cliché instantané ne peut pas continuer, car un gestionnaire de ressources transactionnelles ne peut pas être figé dans son état actuel.  Veuillez réessayer.
'Error 6729 'Impossible d’inscrire la transaction avec le masque d’inscription spécifié, car la transaction a déjà terminé la phase de pré-préparation. Pour garantir l’exactitude du processus, le Gestionnaire de ressources doit passer en mode d’écriture continue et arrêter
'Error 6730 'Cette transaction n’a pas d’enrôlement supérieur.
'Error 6731 'La tentative de validation de la transaction est terminée, mais il est possible qu’une partie de l’arborescence de la transaction n'ait pas été validée en raison de l’heurastique. Il se peut par conséquent que certaines données modifiées dans la transaction n’
'Error 6800 'La fonction a tenté d’utiliser un nom dont l’utilisation est réservée à une autre transaction.
'Error 6801 'La prise en charge des transactions dans le gestionnaire de ressources spécifié n’est pas démarrée ou a été arrêtée en raison d’une erreur.
'Error 6802 'Les métadonnées du Gestionnaire de ressources ont été endommagées. Le Gestionnaire de ressources ne fonctionnera pas.
'Error 6803 'Le répertoire spécifié ne contient pas de Gestionnaire de ressources.
'Error 6805 'Le serveur ou le partage distant ne prend pas en charge les opérations de fichier traitées avec transaction.
'Error 6806 'Taille de journal demandée non valide.
'Error 6807 'L’objet (fichier, flux, lien) correspondant au descripteur a été supprimé par une restauration au point de sauvegarde de la transaction.
'Error 6808 'Miniversion du fichier spécifié introuvable pour ce fichier traité ouvert.
'Error 6809 'La miniversion du fichier spécifié a été trouvée mais a été invalidée. Cela est probablement dû à la restauration au point de sauvegarde de la transaction.
'Error 6810 'Une miniversion peut être ouverte uniquement dans le cadre de la transaction qui l’a créée.
'Error 6811 'Impossible d’ouvrir une miniversion avec un accès en modification.
'Error 6812 'Impossible de créer davantage de miniversions pour ce flux.
'Error 6814 'Le serveur distant a envoyé un numéro de version ou un Fid incompatible pour un fichier ouvert avec des transactions.
'Error 6815 'Le handle a été invalidé par une transaction. La raison la plus probable en est la présence de mappage mémoire sur un fichier ou un handle ouvert quand la transaction s’est terminée ou qu’elle a été restaurée à un point d’enregistrement.
'Error 6816 'Il n’existe pas de métadonnées de transaction sur le fichier.
'Error 6817 'Les données du journal sont endommagées.
'Error 6818 'Impossible de récupérer le fichier car un descripteur est toujours ouvert sur le fichier.
'Error 6819 'Le résultat de la transaction n’est pas disponible car le Gestionnaire de ressources chargé de la transaction s’est déconnecté.
'Error 6820 'La demande a été rejetée car l’enrôlement en question n’est pas un enrôlement supérieur.
'Error 6821 'L’état du Gestionnaire de ressources de transaction est déjà cohérent. La récupération n’est pas nécessaire.
'Error 6822 'Le Gestionnaire de ressources de transaction est déjà démarré.
'Error 6823 'Impossible d’ouvrir le fichier de façon transactionnelle car l’identité du fichier dépend du résultat d’une transaction non résolue.
'Error 6824 'Impossible d’effectuer cette opération car une autre transaction dépend du fait que cette propriété ne changera pas.
'Error 6825 'L’opération impliquerait un fichier unique avec deux Gestionnaires de ressources de transaction ; par conséquent, elle n’est pas autorisée.
'Error 6826 'Le répertoire $Txf doit être vide pour que cette opération réussisse.
'Error 6827 'L’opération laisserait un gestionnaire de ressources de transaction dans un état incohérent ; par conséquent, elle n’est pas autorisée.
'Error 6828 'Impossible de terminer l’opération car le gestionnaire de transactions n’a pas de journal.
'Error 6829 'Impossible de programmer une restauration car une restauration précédemment programmée a déjà été exécutée ou mise en file d’attente pour exécution.
'Error 6830 'L’attribut de métadonnées transactionnelles du fichier ou du répertoire est endommagé et illisible.
'Error 6831 'Impossible de terminer le chiffrement car une transaction est active.
'Error 6832 'L’ouverture de cet objet n’est pas autorisée dans une transaction.
'Error 6833 'Échec de la création de l’espace dans le journal du gestionnaire des ressources de transaction. L’état d’échec a été enregistré dans le journal des événements.
'Error 6834 'Le mappage de mémoire (création d’une section mappée) d’un fichier à distance sous une transaction n’est pas pris en charge.
'Error 6835 'Des métadonnées transactionnelles sont déjà présentes dans ce fichier et ne peuvent être remplacées.
'Error 6836 'Impossible d’entrer une étendue de transaction car le gestionnaire d’étendue n’a pas été initialisé.
'Error 6837 'La promotion était requise afin d’autoriser le gestionnaire de ressources à enrôler, mais la transaction était définie pour la désactiver.
'Error 6838 'Ce fichier est ouvert pour modification dans une transaction non résolue et il ne peut être ouvert pour exécution que par un lecteur par transaction.
'Error 6839 'La demande de déblocage des transactions figées a été ignorée car les transactions n’avaient jamais été figées auparavant.
'Error 6840 'Impossible de figer les transactions car un blocage est déjà en cours.
'Error 6841 'Le volume cible n’est pas un instantané de volume. Cette opération est valide uniquement sur un volume monté en instantané.
'Error 6842 'Échec de l’opération de point de sauvegarde car des fichiers sont ouverts sur la transaction. Cela n’est pas autorisé.
'Error 6843 'Windows a détecté des données endommagées dans un fichier qui a depuis été réparé. Il est possible que des données aient été perdues.
'Error 6844 'Impossible de terminer la fragmentation car une transaction est active sur le fichier.
'Error 6845 'L’appel pour créer un objet TransactionManager a échoué car l’identité du gestionnaire de transactions stockée dans le fichier journal ne correspond pas à l’identité du gestionnaire de transactions passée en tant qu’argument.
'Error 6846 'Tentative d’entrée/sortie sur un objet section qui a été exempté en tant que résultat d’une fin de transaction. Il n’y a pas de données valides.
'Error 6847 'Le gestionnaire de ressources de transaction ne peut pas accepter actuellement de tâches basées sur les transactions, en raison d’une situation transitoire (niveau de ressources faible, par exemple).
'Error 6848 'Le gestionnaire de ressources de transaction avait un trop grand nombre de transactions en attente qui n’ont pas pu être interrompues. Le gestionnaire de ressources de transaction a été arrêté.
'Error 6849 'L’opération n’a pas abouti en raison de clusters endommagés sur disque.
'Error 6850 'Impossible d’effectuer l’opération de compression car une transaction est active sur le fichier.
'Error 6851 'L’opération n’a pas pu se terminer car le volume est endommagé. Exécutez chkdsk et reéssayez.
'Error 6852 'Impossible de réaliser l’opération de suivi de lien car une transaction est active.
'Error 6853 'Cette opération ne peut pas être effectuée dans une transaction.
'Error 6854 'Le handle n’est plus correctement associé à sa transaction. Il a peut-être été ouvert dans un gestionnaire de ressources de transaction qui a été par la suite forcé à redémarrer. Fermez le handle et ouvrez-en un nouveau.
'Error 6855 'L’opération spécifiée n’a pas pu être exécutée car le gestionnaire de ressources n’est pas inscrit dans la transaction.
'Error 7001 'Le nom de session spécifié n’est pas valide.
'Error 7002 'Le pilote de protocole spécifié n’est pas valide.
'Error 7003 'Le pilote de protocole spécifié n’a pas été trouvé dans le chemin d’accès système.
'Error 7004 'Le pilote de connexion de terminal spécifié n’a pas été trouvé dans le chemin d’accès système.
'Error 7005 'Impossible de créer une clé de Registre pour l’enregistrement des événements pour cette session.
'Error 7006 'Un service portant le même nom existe déjà sur le système.
'Error 7007 'Une opération de fermeture est en attente pour la session.
'Error 7008 'Aucune mémoire tampon de sortie n’est disponible.
'Error 7009 'Impossible de trouver le fichier MODEM.INF.
'Error 7010 'Impossible de trouver le nom du modem dans MODEM.INF.
'Error 7011 'Le modem n’a pas accepté la commande qui lui a été envoyée. Vérifiez que le nom du modem configuré correspond au modem installé.
'Error 7012 'Le modem n’a pas répondu à la commande qui lui a été envoyée. Vérifiez que le modem est correctement câblé et allumé.
'Error 7013 'La détection de porteuse a échoué ou la porteuse a été perdue suite à une déconnexion.
'Error 7014 'Impossible de détecter la tonalité pendant le délai imparti. Vérifiez que le câble du téléphone est correctement branché et fonctionne.
'Error 7015 'Le signal Occupé a été détecté sur le site distant lors du rappel.
'Error 7016 'Une voix a été détectée sur le site distant pendant le rappel.
'Error 7017 'Erreur du pilote de transport.
'Error 7022 'Impossible de trouver la session spécifiée.
'Error 7023 'Le nom de la session spécifié est déjà utilisé.
'Error 7024 'La tâche que vous essayez de réaliser ne peut pas se terminer car le service Bureau à distance est actuellement occupé. Réessayez dans quelques minutes. Cela ne devrait pas empêcher d’autres utilisateurs d’ouvrir une session.
'Error 7025 'Une tentative de connexion à une session dont le mode vidéo n’est pas pris en charge par le client actuel a été effectuée.
'Error 7035 'L’application a tenté d’activer le mode graphique DOS. Le mode graphique DOS n’est pas pris en charge.
'Error 7037 'Votre privilège d’ouverture de session interactive a été désactivé. Contactez votre administrateur.
'Error 7038 'L’opération requise ne peut être effectuée que sur la console système. C’est généralement le résultat d’un pilote ou d’une DLL système qui requiert un accès direct à la console.
'Error 7040 'Le client n’a pas répondu au message de connexion du serveur.
'Error 7041 'La déconnexion de la session de la console n’est pas prise en charge.
'Error 7042 'La reconnexion d’une session déconnectée à la console n’est pas prise en charge.
'Error 7044 'La requête pour contrôler une autre session à distance a été refusée.
'Error 7045 'L’accès à la session requis est refusé.
'Error 7049 'Le pilote de connexion de terminal spécifié n’est pas valide.
'Error 7050 'La session requise ne peut pas être contrôlée à distance. Ceci peut arriver si la session est déconnectée ou n’a pas actuellement d’utilisateur connecté.
'Error 7051 'La session requise n’est pas configurée pour autoriser le contrôle à distance.
'Error 7052 'Votre demande de connexion à ce serveur Terminal Server a été rejetée. Votre numéro de licence client Terminal Server est utilisé par une autre personne. Appelez votre administrateur système pour obtenir un numéro de licence valide unique.
'Error 7053 'Votre demande de connexion à ce serveur Terminal Server a été rejetée. Votre numéro de licence client Terminal Server n’a pas été entré pour cette copie du client Terminal Server. Contactez votre administrateur système.
'Error 7054 'Le nombre de connexions à cet ordinateur est limité et toutes les connexions sont actuellement utilisées. Essayez de vous connecter plus tard ou contactez votre administrateur système.
'Error 7055 'Le client que vous utilisez ne possède pas de licence pour utiliser ce système. Votre demande d’ouverture de session est refusée.
'Error 7056 'La licence du système a expiré. Demande d’ouverture de session refusée.
'Error 7057 'Le contrôle à distance n’a pas pu être terminé car la session spécifiée n’est actuellement pas contrôlée à distance.
'Error 7058 'Le contrôle à distance de la console a été terminé car le mode d’affichage à été modifié. La modification du mode d’affichage en cours de session de contrôle à distance n’est pas prise en charge.
'Error 7059 'L’activation a déjà été réinitialisée un nombre maximal de fois pour cette installation. Votre minuteur d’activation ne sera pas effacé.
'Error 7060 'Les ouvertures de sessions distantes sont actuellement désactivées.
'Error 7061 'Vous ne disposez pas du niveau de chiffrement nécessaire pour accéder à cette session.
'Error 7062 'L’utilisateur %s\\%s a ouvert une session sur cet ordinateur. Seul l’utilisateur actuel ou un administrateur peut ouvrir une session sur cet ordinateur.
'Error 7063 'L’utilisateur %s\\%s a déjà ouvert une session sur la console de cet ordinateur. Vous n’avez pas l’autorisation d’ouvrir une session actuellement. Pour résoudre ce problème, contactez %s\\%s pour que l’utilisateur ferme la session.
'Error 7064 'Impossible d’ouvrir une session car il y a une limitation des comptes.
'Error 7065 'Le composant %2 du protocole RDP a détecté une erreur dans le flux du protocole et a déconnecté le client.
'Error 7066 'Le Service de mappage de lecteurs clients s’est connecté à la Connexion de terminal.
'Error 7067 'Le Service de mappage de lecteurs clients s’est déconnecté de la Connexion de terminal.
'Error 7068 'La couche de sécurité des services Terminal Server a détecté une erreur dans le flux du protocole et a déconnecté le client.
'Error 7069 'La session cible est incompatible avec la session actuelle.
'Error 7070 'Windows ne peut pas se connecter à votre session en raison d’un problème dans le sous-système vidéo de Windows. Réessayez de vous connecter ultérieurement ou contactez l’administrateur du serveur pour obtenir de l’aide.
'Error 8001 'L’API du service de réplication de fichiers a été appelée de manière incorrecte.
'Error 8002 'Impossible de démarrer le service de réplication de fichiers.
'Error 8003 'Impossible d’arrêter le service de réplication de fichiers.
'Error 8004 'L’API du service de réplication de fichiers a terminé la requête. Le journal des événements peut contenir plus d’informations.
'Error 8005 'Le service de réplication de fichiers a terminé la requête. Le journal des événements peut contenir plus d’informations.
'Error 8006 'Impossible de contacter le service de réplication de fichiers. Le journal des événements peut contenir plus d’informations.
'Error 8007 'Impossible pour le service de réplication de fichiers de satisfaire la demande car l’utilisateur ne possède pas les droits suffisants. Le journal des événements peut contenir plus d’informations.
'Error 8008 'Impossible pour le service de réplication de fichiers de satisfaire la demande car le RPC authentifié n’est pas disponible. Le journal des événements peut contenir plus d’informations.
'Error 8009 'Impossible pour le service de réplication de fichiers de satisfaire la demande car l’utilisateur n’a pas les droits suffisants sur le contrôleur de domaine. Le journal des événements peut contenir plus d’informations.
'Error 8010 'Impossible pour le service de réplication de fichiers de satisfaire la demande car le RPC authentifié n’est pas disponible sur le contrôleur de domaine. Le journal des événements peut contenir plus d’informations.
'Error 8011 'Impossible pour le service de réplication de fichiers de communiquer avec le service de réplication de fichiers sur le contrôleur de domaine. Le journal des événements peut contenir plus d’informations.
'Error 8012 'Impossible pour le service de réplication de fichiers du contrôleur de domaine de communiquer avec le service de réplication de fichiers sur cet ordinateur. Le journal des événements peut contenir plus d’informations.
'Error 8013 'Impossible pour le service de réplication de fichiers d’enregistrer les données dans le volume système en raison d’une erreur interne. Le journal des événements peut contenir plus d’informations.
'Error 8014 'Impossible pour le service de réplication de fichiers d’enregistrer les données dans le volume système en raison d’un délai d’attente interne. Le journal des événements peut contenir plus d’informations.
'Error 8015 'Impossible pour le service de réplication de traiter la requête. Le volume système est occupé avec une requête précédente.
'Error 8016 'Impossible pour le service de réplication d’arrêter la réplication du volume système en raison d’une erreur interne. Le journal des événements peut contenir plus d’informations.
'Error 8017 'Le service de réplication de fichiers a détecté un paramètre non valide.
'Error 8200 'Erreur lors de l’installation du service d’annuaire. Pour plus d’informations, consultez le journal des événements.
'Error 8201 'Le service d’annuaires a évalué les adhésions de groupe localement.
'Error 8202 'L’attribut ou la valeur de service d’annuaire spécifié n’existe pas.
'Error 8203 'La syntaxe d’attribut spécifiée au service d’annuaire n’est pas valide.
'Error 8204 'Le type d’attribut spécifié au service d’annuaire n’est pas défini.
'Error 8205 'L’attribut ou la valeur de service d’annuaire spécifié existe déjà.
'Error 8206 'Le service d’annuaire est occupé.
'Error 8207 'Le service d’annuaire n’est pas disponible.
'Error 8208 'Le service d’annuaire n’a pas pu allouer un identificateur relatif.
'Error 8209 'Le service d’annuaire a épuisé la réserve d’identificateurs relatifs.
'Error 8210 'L’opération demandée n’a pas pu être effectuée car le service d’annuaire n’est pas le service directeur pour ce type d’opération.
'Error 8211 'Le service d’annuaire n’a pas pu initialiser le sous-système qui alloue les identificateurs relatifs.
'Error 8212 'L’opération demandée n’est pas compatible avec l’une ou plusieurs des contraintes associées avec la classe de l’objet.
'Error 8213 'Le service d’annuaire ne peut effectuer l’opération requise que sur un objet Nœud terminal.
'Error 8214 'Le service d’annuaire ne peut pas effectuer l’opération requise sur l’attribut RDN d’un objet.
'Error 8215 'Le service d’annuaire a détecté une tentative de modification de la classe d’objet d’un objet.
'Error 8216 'L’opération de déplacement entre domaines requise n’a pas pu être effectuée.
'Error 8217 'Impossible de contacter le serveur de catalogue global.
'Error 8218 'L’objet Stratégie est partagé et ne peut être modifié qu’à la racine.
'Error 8219 'L’objet Stratégie n’existe pas.
'Error 8220 'Les informations de stratégie requises ne sont présentes que dans le service d’annuaire.
'Error 8221 'Une promotion de contrôleur de domaine est en cours.
'Error 8222 'Aucune promotion de contrôleur de domaine n’est en cours.
'Error 8224 'Une erreur d’opération s’est produite.
'Error 8225 'Une erreur de protocole s’est produite.
'Error 8226 'Dépassement de la limite de temps pour cette requête.
'Error 8227 'Dépassement de la limite de taille pour cette requête.
'Error 8228 'Dépassement de la limite administrative pour cette requête.
'Error 8229 'La comparaison de réponse était fausse.
'Error 8230 'La comparaison de réponse était vraie.
'Error 8231 'La méthode d’authentification demandée n’est pas prise en charge par le serveur.
'Error 8232 'Une méthode d’authentification plus sécurisée est nécessaire pour ce serveur.
'Error 8233 'Authentification inappropriée.
'Error 8234 'Mécanisme d’authentification inconnu.
'Error 8235 'Une référence a été renvoyée par le serveur.
'Error 8236 'Le serveur ne prend pas en charge l’extension critique demandée.
'Error 8237 'Cette requête nécessite une connexion sécurisée.
'Error 8238 'Correspondance inappropriée.
'Error 8239 'Une violation de contrainte s’est produite.
'Error 8240 'Cet objet ne se trouve pas sur le serveur.
'Error 8241 'Problème d’alias.
'Error 8242 'Une syntaxe DN non valide a été spécifiée.
'Error 8243 'L’objet est un objet Nœud terminal.
'Error 8244 'Problème de déférence d’alias.
'Error 8245 'Le serveur ne souhaite pas traiter la requête.
'Error 8246 'Une boucle a été détectée.
'Error 8247 'Violation de nom.
'Error 8248 'L’ensemble du résultat est trop volumineux.
'Error 8249 'L’opération affecte plusieurs DSA
'Error 8250 'Le serveur n’est pas opérationnel.
'Error 8251 'Une erreur locale s’est produite.
'Error 8252 'Une erreur de codage s’est produite.
'Error 8253 'Une erreur de décodage s’est produite.
'Error 8254 'Le filtre de recherche n’est pas reconnu.
'Error 8255 'Un ou plusieurs paramètres ne sont pas autorisés.
'Error 8256 'La méthode spécifiée n’est pas prise en charge.
'Error 8257 'Aucun résultat n’a été renvoyé.
'Error 8258 'Le contrôle spécifié n’est pas prise en charge par le serveur.
'Error 8259 'Une boucle de référence a été détectée par le client.
'Error 8260 'La limite de référence prédéfinie a été dépassée.
'Error 8261 'La recherche nécessite un contrôle SORT.
'Error 8262 'Les résultats de la recherche dépassent la plage de décalage spécifiée.
'Error 8263 'Le service d’annuaire a détecté que le sous-système qui alloue les identificateurs relatifs est désactivé. Ceci peut se produire en tant que mécanisme de protection lorsque le système détermine qu’une partie significative des identificateurs relatifs (RID) est
'Error 8301 'L’objet racine doit être à la tête du contexte de nommage. L’objet racine ne peut pas avoir de parent instancié.
'Error 8302 'Impossible d’effectuer l’opération d’ajout de réplica. Le contexte de nommage doit être ouvert en écriture afin de créer la réplica.
'Error 8303 'Une référence à un attribut non défini dans le schéma s’est produite.
'Error 8304 'La taille maximale d’un objet a été dépassée.
'Error 8305 'Une tentative d’ajout d’un objet dans l’annuaire avec un nom déjà utilisé s’est produite.
'Error 8306 'Une tentative d’ajout d’un objet d’une classe qui n’a pas de RDN défini dans le schéma s’est produite.
'Error 8307 'Une tentative d’ajout d’un objet utilisant un RDN qui n’est pas le RDN défini dans le schéma s’est produite.
'Error 8308 'Aucun des attributs requis n’a été trouvé sur les objets.
'Error 8309 'La mémoire tampon de l’utilisateur est insuffisante.
'Error 8310 'L’attribut spécifié dans l’opération n’est pas présent sur l’objet.
'Error 8311 'Opération de modification non autorisée. Une partie de la modification n’est pas autorisée.
'Error 8312 'L’objet spécifié est trop important en taille.
'Error 8313 'Le type d’instance spécifié n’est pas valide.
'Error 8314 'L’opération doit être effectuée sur un DSA principal.
'Error 8315 'L’attribut de classe d’objet doit être spécifié.
'Error 8316 'Un attribut nécessaire n’est pas présent.
'Error 8317 'Une tentative de modifier un objet pour inclure un attribut non autorisé pour sa classe s’est produite.
'Error 8318 'L’attribut spécifié est déjà présent sur l’objet.
'Error 8320 'L’attribut spécifié n’est pas présent ou n’a aucune valeur.
'Error 8321 'Plusieurs valeurs ont été spécifiées pour un attribut qui ne peut avoir qu’une seule valeur.
'Error 8322 'Une valeur de l’attribut n’était pas dans la plage de valeurs acceptables.
'Error 8323 'La valeur spécifiée existe déjà.
'Error 8324 'Impossible de déplacer l’attribut car il n’est pas présent sur l’objet.
'Error 8325 'Impossible de supprimer la valeur de l’attribut car elle n’est pas présente sur l’objet.
'Error 8326 'L’objet racine spécifié ne peut pas être une sous-référence.
'Error 8327 'Le chaînage n’est pas autorisé.
'Error 8328 'Une évaluation par enchaînement n’est pas autorisée.
'Error 8329 'L’opération n’a pas pu être effectuée car le parent de l’objet n’est pas instancié ou a été supprimé.
'Error 8330 'Il n’est pas autorisé d’avoir un alias comme parent. Les alias sont des objets de type Nœud terminal.
'Error 8331 'L’objet et le parent doivent être de même type  'ils doivent tout deux être soit des objets principaux, soit des réplicas.
'Error 8332 'Impossible d’effectuer l’opération car des objets enfants existent. Cette opération ne peut être effectuée que sur un objet Nœud terminal.
'Error 8333 'Objet de l’annuaire non trouvé.
'Error 8334 'L’objet disposant d’un alias n’est pas présent.
'Error 8335 'La syntaxe du nom de l’objet est incorrecte.
'Error 8336 'Il n’est pas permis à un alias de faire référence à un autre alias.
'Error 8337 'Il est impossible d’enlever la référence de l’alias.
'Error 8338 'L’opération est en dehors de son contexte.
'Error 8339 'L’opération ne peut pas continuer car l’objet est en cours de suppression.
'Error 8340 'Impossible de supprimer l’objet DSA.
'Error 8341 'Une erreur de service d’annuaire s’est produite.
'Error 8342 'L’opération ne peut être effectuée que sur un objet DSA principal interne.
'Error 8343 'L’objet doit être de classe DSA.
'Error 8344 'Droits d’accès insuffisants pour effectuer cette opération.
'Error 8345 'Impossible d’ajouter l’objet car le parent ne fait pas partie de la liste des supérieurs possibles.
'Error 8346 'L’accès à l’attribut n’est pas autorisé car l’attribut appartient au Gestionnaire des comptes de sécurité (SAM).
'Error 8347 'Le nom est composé d’un trop grand nombre de parties.
'Error 8348 'Le nom est trop long.
'Error 8349 'La valeur du nom est trop longue.
'Error 8350 'Active Directory a rencontré une erreur en analysant un nom.
'Error 8351 'Active Directory n’a pas pu obtenir le type d’attribut d’un nom.
'Error 8352 'Le nom n’identifie pas un objet ; le nom identifie un fantôme.
'Error 8353 'Le descripteur de sécurité est trop court.
'Error 8354 'Le descripteur de sécurité n’est pas valide.
'Error 8355 'Échec lors de la création d’un nom pour l’objet supprimé.
'Error 8356 'Le parent d’une nouvelle sous-référence doit exister.
'Error 8357 'L’objet doit être un contexte de nommage.
'Error 8358 'Il n’est pas autorisé d’ajouter un attribut appartenant au système.
'Error 8359 'La classe de l’objet doit être structurelle ; vous ne pouvez pas instancier une classe abstraite.
'Error 8360 'Impossible de trouver l’objet schéma.
'Error 8361 'Un objet local portant ce GUID (mort ou vivant) existe déjà.
'Error 8362 'Impossible d’effectuer l’opération sur une liaison secondaire.
'Error 8363 'Impossible de trouver la référence croisée pour le contexte de nommage spécifié.
'Error 8364 'L’opération ne peut pas être effectuée car le service d’annuaire est en cours d’arrêt.
'Error 8365 'La requête Active Directory n’est pas valide.
'Error 8366 'Impossible de lire l’attribut du propriétaire du rôle.
'Error 8367 'L’opération FSMO demandée a échoué. Le propriétaire FMSO actuel n’a pas pu être contacté.
'Error 8368 'Il n’est pas autorisé de modifier un DN via un contexte de nommage.
'Error 8369 'Impossible de modifier l’attribut car il appartient au système.
'Error 8370 'Seul le duplicateur peut effectuer cette fonction.
'Error 8371 'La classe spécifiée n’est pas définie.
'Error 8372 'La classe spécifiée n’est pas une sous-classe.
'Error 8373 'La référence de nom n’est pas valide.
'Error 8374 'Une référence croisée existe déjà.
'Error 8375 'La suppression d’une référence croisée principale n’est pas autorisée.
'Error 8376 'Les notifications de sous-arborescence ne sont prises en charge que par les NC principaux.
'Error 8377 'Le filtre de notification est trop complexe.
'Error 8378 'Échec de la mise à jour de schéma  'RDN dupliqué.
'Error 8379 'Échec de la mise à jour de schéma  'OID dupliqué.
'Error 8380 'Échec de la mise à jour de schéma  'identificateur MAPI dupliqué.
'Error 8381 'Échec de la mise à jour de schéma  'GUID de schema-id dupliqué.
'Error 8382 'Échec de la mise à jour de schéma  'nom complet LDAP dupliqué.
'Error 8383 'Échec de la mise à jour de schéma  'le minimum de l’étendue est supérieur au maximum de l’étendue.
'Error 8384 'Échec de la mise à jour de schéma  'correspondance incorrecte de la syntaxe.
'Error 8385 'Échec de la suppression de schéma  'un attribut est utilisé (must-contain).
'Error 8386 'Échec de la suppression de schéma  'un attribut est utilisé (may-contain).
'Error 8387 'Échec de la mise à jour de schéma  'aucun attribut à valeur facultative.
'Error 8388 'Échec de la mise à jour de schéma  'aucun attribut à valeur obligatoire.
'Error 8389 'La mise à jour du schéma a échoué  'la classe dans aux-Class n’existe pas ou n’est pas une classe auxiliaire.
'Error 8390 'La mise à jour du schéma a échoué  'La classe de poss superior n’existe pas.
'Error 8391 'La mise à jour du schéma a échoué  'La classe de la liste subclassof n’existe pas ou n’observe pas les règles de hiérarchie.
'Error 8392 'La mise à jour du schéma a échoué  'La syntaxe de Rdn-Att-Id est erronée.
'Error 8393 'Impossible de supprimer le schéma  'La classe est utilisée en tant que classe auxiliaire.
'Error 8394 'Impossible de supprimer le schéma  'La classe est utilisée en tant que sous-classe.
'Error 8395 'Impossible de supprimer le schéma  'La classe est utilisée en tant que poss superior.
'Error 8396 'La mise à jour du schéma a échoué lors du recalcul du cache de validation.
'Error 8397 'La suppression de l’arborescence n’est pas terminée. Il faut refaire la demande pour continuer la suppression de l’arborescence.
'Error 8398 'L’opération de suppression demandée n’a pas pu être effectuée.
'Error 8399 'Impossible de lire l’identificateur de classe governs pour l’enregistrement du schéma.
'Error 8400 'La syntaxe du schéma de l’attribut est incorrecte.
'Error 8401 'Il n’a pas été possible de mettre l’attribut en cache.
'Error 8402 'Il n’a pas été possible de mettre la classe en cache.
'Error 8403 'L’attribut n’a pas pu être supprimé du cache.
'Error 8404 'La classe n’a pas pu être supprimée du cache.
'Error 8405 'Il n’a pas été possible de lire l’attribut du nom distinct.
'Error 8406 'Aucune référence supérieure n’a été configurée pour le service de répertoire. Le service de répertoire est par conséquent incapable d’émettre des références aux objets en dehors de cette forêt.
'Error 8407 'Il n’a pas été possible de récupérer l’attribut de type d’instance.
'Error 8408 'Une erreur interne s’est produite.
'Error 8409 'Une erreur de base de données s’est produite.
'Error 8410 'L’attribut GOVERNSID n’est pas présent.
'Error 8411 'Un attribut nécessaire n’est pas présent.
'Error 8412 'Une référence croisée manque au contexte de nommage spécifié.
'Error 8413 'Une erreur de vérification de sécurité s’est produite.
'Error 8414 'Le schéma n’est pas chargé.
'Error 8415 'L’allocation de schéma a échoué. Veuillez vérifier la mémoire disponible de l’ordinateur.
'Error 8416 'Impossible d’obtenir la syntaxe exigée pour le schéma d’attributs.
'Error 8417 'La vérification du catalogue global a échoué. Le catalogue global n’est pas disponible ou ne prend pas en charge l’opération. Une partie de l’annuaire n’est pas disponible actuellement.
'Error 8418 'L’opération de réplication a échoué en raison d’une correspondance de schémas incorrecte entre les serveurs impliqués.
'Error 8419 'Impossible de trouver l’objet DSA.
'Error 8420 'Impossible de trouver le contexte de nommage.
'Error 8421 'Impossible de trouver le contexte de nommage dans le cache.
'Error 8422 'Impossible de récupérer l’objet enfant.
'Error 8423 'La modification n’a pas été autorisée pour des raisons de sécurité.
'Error 8424 'L’opération ne peut pas remplacer les enregistrements cachés.
'Error 8425 'Le fichier de hiérarchie n’est pas valide.
'Error 8426 'Échec de la tentative de construction de la table de hiérarchie.
'Error 8427 'Le paramètre de configuration de l’annuaire manque dans le Registre.
'Error 8428 'Échec de la tentative de compter les indices du carnet d’adresses.
'Error 8429 'Échec de l’allocation pour la table de hiérarchie.
'Error 8430 'Active Directory a rencontré une défaillance interne.
'Error 8431 'Active Directory a rencontré une défaillance inconnue.
'Error 8432 'Un objet racine nécessite une classe issue de 'top'.
'Error 8433 'Ce serveur d’annuaire est en cours d’arrêt et ne peut pas recevoir de nouveaux rôles d’opération en tant que maître unique flottant.
'Error 8434 'Il manque des informations de configuration au service d’annuaire, qui ne peut pas déterminer le propriétaire des rôles d’opération en tant que maître unique flottant.
'Error 8435 'Le service d’annuaire n’a pas pu transférer la propriété d’un ou plusieurs rôles d’opération en tant que maître unique flottant à d’autres serveurs.
'Error 8436 'Échec d’une opération de réplication.
'Error 8437 'Un paramètre non valide a été spécifié pour cette opération de réplication.
'Error 8438 'Le service d’annuaire est occupé et ne peut pas terminer l’opération de réplication actuellement.
'Error 8439 'Le nom unique spécifié pour cette opération de réplication n’est pas valide.
'Error 8440 'Le contexte de définition de nom spécifié pour cette opération de réplication n’est pas valide.
'Error 8441 'Le nom unique spécifié pour cette opération de réplication existe déjà.
'Error 8442 'Le système de réplication a rencontré une erreur interne.
'Error 8443 'L’opération de réplication a rencontré une incohérence dans la base de données.
'Error 8444 'Le nom de serveur spécifié pour cette opération de réplication n’a pas pu être contacté.
'Error 8445 'L’opération de réplication a rencontré un objet dont le type d’instance n’est pas valide.
'Error 8446 'L’opération de réplication n’est pas parvenue à allouer la mémoire.
'Error 8447 'Le système de réplication a rencontré une erreur avec le système de messagerie.
'Error 8448 'Les informations de référence de réplication pour le serveur cible existent déjà.
'Error 8449 'Les informations de référence de réplication pour le serveur cible n’existent pas.
'Error 8450 'Impossible de supprimer le contexte de nommage car il est dupliqué sur un autre serveur.
'Error 8451 'L’opération de réplication a rencontré une erreur dans la base de données.
'Error 8452 'Le contexte de nommage est prêt à être supprimé ou bien n’est pas dupliqué à partir du serveur spécifié.
'Error 8453 'L’accès à la réplication a été refusé.
'Error 8454 'L’opération demandée n’est pas prise en charge par cette version de Active Directory.
'Error 8455 'L’appel de procédure de réplication distante a été annulé.
'Error 8456 'Le serveur source rejette actuellement les demandes de réplication.
'Error 8457 'Le serveur de destination rejette actuellement les demandes de réplication.
'Error 8458 'L’opération de réplication a échoué en raison d’une collision entre noms d’objets.
'Error 8459 'La source de réplication a été réinstallée.
'Error 8460 'L’opération de réplication a échoué car un objet parent nécessaire n’est pas présent.
'Error 8461 'L’opération de réplication a été anticipée.
'Error 8462 'La tentative de synchronisation de la réplication a été arrêtée car il y a trop peu de mises à jour.
'Error 8463 'L’opération de réplication s’est arrêtée car le système est en cours d’arrêt.
'Error 8464 'La tentative de synchronisation de la réplication a échoué car le contrôleur de domaine destination est actuellement en attente de synchronisation de nouveaux attributs partiels à partir de la source. Cette condition est normale si une modification récente du
'Error 8465 'La tentative de synchronisation de la réplication a échoué car un réplica principal a tenté de se synchroniser à partir d’un réplica partiel.
'Error 8466 'Le serveur spécifié pour cette opération de réplication a été contacté mais il n’a pas pu établir de liaison avec un serveur supplémentaire requis pour terminer cette opération .
'Error 8467 'La version du schéma du service d’annuaire de la forêt source n’est pas compatible avec la version du service d’annuaire sur cet ordinateur.
'Error 8468 'La mise à jour de schéma a échoué  'Un attribut avec le même identificateur de lien existe déjà
'Error 8469 'Traduction du nom  'Erreur de traitement générique.
'Error 8470 'Traduction du nom  'Nom introuvable ou autorisation insuffisante pour voir le nom.
'Error 8471 'Traduction du nom  'Le nom d’entrée correspond à plusieurs noms de sortie.
'Error 8472 'Traduction du nom  'Le nom d’entrée a été trouvé mais pas le format de sortie associé.
'Error 8473 'Traduction de nom  'Il n’a pu être résolu complètement ; seul un domaine a été trouvé.
'Error 8474 'Traduction de nom  'Impossible d’exécuter le mappage syntaxique pur sur le client sans établir une connexion externe.
'Error 8475 'La modification d’un attribut construit n’est pas autorisée.
'Error 8476 'Le schéma d’attribut OM-Object-Class spécifié est incorrect pour un attribut avec la syntaxe spécifiée.
'Error 8477 'La requête de réplication a été envoyée ; attente d’une réponse.
'Error 8478 'L’opération demandée nécessite un service d’annuaire mais aucun n’est disponible.
'Error 8479 'Le nom complet LDAP de la classe ou de l’attribut contient des caractères non ASCII.
'Error 8480 'L’opération de recherche demandée n’est prise en charge que pour les recherches de base.
'Error 8481 'La recherche n’a pas pu récupérer les attributs à partir de la base de données.
'Error 8482 'L’opération de mise à jour du schéma a essayé d’ajouter un attribut de lien précédent qui n’a pas de lien suivant qui lui correspond.
'Error 8483 'Le départ et la destination d’un déplacement entre domaines ne sont pas cohérents sur le numéro de version de l’objet. Soit la source soit la destination n’a pas la dernière version de l’objet.
'Error 8484 'La source et la destination d’un déplacement entre domaines ne sont pas cohérents sur le nom courant de l’objet. Soit la source soir la destination n’a pas la dernière version de l’objet.
'Error 8485 'La source et la destination pour l’opération de déplacement entre domaines sont identiques. L’appelant doit utiliser l’opération de déplacement locale au lieu de l’opération de déplacement entre domaines.
'Error 8486 'La source et la destination pour un déplacement entre domaines ne sont pas cohérents sur les contextes de nommage dans la forêt. Soit la source, soit la destination n’ont pas la dernière version du conteneur de partition.
'Error 8487 'La destination d’un déplacement entre domaines ne fait pas autorité pour le contexte de nommage de la destination.
'Error 8488 'La source et la destination d’un déplacement entre domaines ne sont pas cohérents sur l’identité de l’objet source. Soit la source, soit la destination n’ont pas la dernière version de l’objet source.
'Error 8489 'L’objet déplacé entre domaines est supprimé par le serveur de destination. Le serveur source n’a pas la version la plus récente de l’objet source.
'Error 8490 'Une autre opération qui nécessite un accès exclusif au contrôleur principal de domaine FSMO est déjà en cours.
'Error 8491 'Une opération de déplacement entre domaines a échoué si bien que deux versions de l’objet déplacé existent - dans les domaines de source et de destination. L’objet de destination doit être supprimé pour restaurer le système dans un état cohérent.
'Error 8492 'Cet objet ne doit pas être déplacé au-delà des frontières du domaine car les déplacements entre domaines pour cette classe d’objet ne sont pas autorisés ou l’objet comporte certaines caractéristiques spéciales, par exemple un compte d’approbation ou une RID re
'Error 8493 'Il est impossible de déplacer les objets avec adhésions au delà des frontières du domaine car, une fois déplacé, ceci enfreindrait les conditions d’adhésion du groupe de comptes. Supprimez l’objet de toute adhésion à un groupe de comptes et réessayez.
'Error 8494 'Un en-tête de contexte de nommage doit être l’enfant direct d’un autre en-tête de contexte de nommage, et non pas d’un nœud intérieur.
'Error 8495 'L’annuaire ne peut pas valider le contexte de nom proposé car il ne détient pas de réplica du contexte de nom qui est au dessus du contexte de nom proposé. Assurez-vous que le rôle de maître de nom de domaine est détenu par un serveur configuré en tant que ser
'Error 8496 'Le domaine de destination doit être en mode natif.
'Error 8497 'Il est impossible d’effectuer l’opération car le serveur ne possède aucun conteneur d’infrastructure dans le domaine d’intérêt.
'Error 8498 'Le déplacement entre domaines de groupes de comptes non vides n’est pas autorisé.
'Error 8499 'Le déplacement entre domaines de groupes de ressources non vides n’est pas autorisé.
'Error 8500 'La valeur des indicateurs de recherche pour l’attribut est incorrecte. Le bit ANR n’est valide que sur des attributs de chaînes Unicode ou Teletex.
'Error 8501 'Les suppressions d’arborescences qui commencent à un objet qui a une tête NC comme descendant ne sont pas autorisées.
'Error 8502 'Le service d’annuaire n’a pas pu verrouiller une arborescence en préparation pour une suppression d’arbre car il était utilisé.
'Error 8503 'Le service d’annuaire n’a pas pu identifier la liste d’objets à supprimer lors de la suppression d’arborescence.
'Error 8504 'L’initialisation du Gestionnaire des comptes de sécurité a échoué en raison de l’erreur suivante  '%1. État de l’erreur  '0x%2. Arrêtez le système, puis redémarrez en mode de restauration des services d’annuaire. Consultez le journal des événements pour obteni
'Error 8505 'Seul un administrateur peut modifier la liste des membres d’un groupe d’administration.
'Error 8506 'Impossible de changer l’ID de groupe principal d’un compte de contrôleur de domaine.
'Error 8507 'Une tentative de modification du schéma de base est effectuée.
'Error 8508 'L’ajout d’un nouvel attribut obligatoire à une classe existante, la suppression d’un attribut obligatoire d’une classe existante, ou l’ajout d’un attribut facultatif à la classe spéciale Top qui n’est pas un attribut lien précédant (directement ou par héritage
'Error 8509 'La mise à jour du schéma n’est pas autorisée sur ce contrôleur de domaine car le contrôleur de domaine n’est pas de propriétaire du rôle FSMO du schéma.
'Error 8510 'Un objet de cette classe n’a pas pu être créé sous le conteneur schéma. Vous ne pouvez créer que des objets attribut-schéma et classe-schéma sous le conteneur schéma.
'Error 8511 'L’installation du réplica/enfant n’a pas pu obtenir l’attribut objectVersion du conteneur schéma sur le contrôleur de domaine source. Soit l’attribut manque dans le conteneur schéma, soit les informations d’identification fournies n’ont pas l’autorisation de l
'Error 8512 'L’installation du réplica/enfant n’a pas pu lire l’attribut objectVersion dans la section SCHEMA du fichier schema.ini dans le répertoire system32.
'Error 8513 'Le type de groupe spécifié n’est pas valide.
'Error 8514 'L’imbrication des groupes globaux dans un domaine mixte est impossible si la sécurité est activée pour les groupes.
'Error 8515 'L’imbrication des groupes globaux dans un domaine mixte est impossible si la sécurité est activée pour les groupes.
'Error 8516 'Un groupe global ne peut pas comprendre de groupe local comme membre.
'Error 8517 'Un groupe global ne peut pas comprendre de groupe universel comme membre.
'Error 8518 'Un groupe universel ne peut comprendre aucun groupe local parmi ses membres.
'Error 8519 'Un groupe global ne peut pas comprendre un membre de plusieurs domaines.
'Error 8520 'Un groupe local ne peut pas comprendre un autre groupe local membre de plusieurs domaines.
'Error 8521 'Impossible de désactiver la sécurité de groupe pour un groupe qui comprend des membres principaux.
'Error 8522 'Le chargement du cache de schéma n’a pas pu convertir la chaîne SD sur un objet de schéma de classe.
'Error 8523 'Seuls les serveurs DSA configurés en tant que serveurs de catalogue global devraient être autorisés à tenir le rôle FSMO de Maître de nom de domaine. (S’applique uniquement aux maîtres de nom de domaines Windows 2000)
'Error 8524 'Échec de l’opération DSA en raison d’une défaillance de la recherche DNS.
'Error 8525 'Lors d’une modification du nom d’hôte DNS pour un objet, les valeurs de nom de principal du service ne peuvent rester synchronisées.
'Error 8526 'Impossible de lire l’attribut du descripteur de sécurité.
'Error 8527 'L’objet requis n’a pas été trouvé, mais un objet portant cette clé a été trouvé.
'Error 8528 'La syntaxe de l’attribut lié qui est ajouté n’est pas correcte. Les liens suivants ne peuvent avoir que les syntaxes 2.5.5.1, 2.5.5.7 et 2.5.5.14, et les liens précédents ne peuvent avoir que la syntaxe 2.5.5.1
'Error 8529 'Le Gestionnaire de comptes de sécurité doit obtenir le mot de passe.
'Error 8530 'Le Gestionnaire de comptes de sécurité doit obtenir la clé de démarrage à partir de la disquette.
'Error 8531 'Le service d’annuaire ne peut pas démarrer.
'Error 8532 'Les services d’annuaire n’ont pas pu démarrer.
'Error 8533 'La connexion entre le client et le serveur nécessite une confidentialité du paquet ou mieux.
'Error 8534 'Le domaine source n’est peut-être pas dans la même forêt que la destination.
'Error 8535 'Le domaine de destination doit être dans la forêt.
'Error 8536 'L’opération nécessite que l’audit du domaine de destination soit activé.
'Error 8537 'L’opération n’a pas pu localiser de contrôleur de domaine pour le domaine source.
'Error 8538 'L’objet source doit être un groupe ou un utilisateur.
'Error 8539 'Le SID de l’objet source existe déjà dans la forêt de destination.
'Error 8540 'Les objets source et destination doivent être du même type.
'Error 8541 'L’initialisation du Gestionnaire des comptes de sécurité a échoué en raison de l’erreur suivante  '%1. Statut de l’erreur  '0x%2. Cliquez sur OK pour arrêter le système, puis redémarrez en mode sans échec. Consultez le journal des événements pour obtenir des i
'Error 8542 'Les informations sur le schéma n’ont pas pu être inclues dans la demande de réplication.
'Error 8543 'L’opération de réplication n’a pas pu se terminer à cause d’une incompatibilité de schéma.
'Error 8544 'L’opération de réplication n’a pas pu se terminer à cause de l’incompatibilité d’un schéma précédent.
'Error 8545 'La mise à jour de la réplication n’a pas pu être appliquée parce que soit la source, soit la destination n’a encore reçu d’informations a propos d’une opération de déplacement entre domaines.
'Error 8546 'Le domaine requis n’a pas pu être supprimé parce que des contrôleurs de domaine sont encore des hôtes dans ce domaine.
'Error 8547 'L’opération requise ne peut être exécutée que sur un serveur de catalogue global.
'Error 8548 'Un groupe local ne peut être qu’un membre d’autres groupes se trouvant dans le même domaine.
'Error 8549 'Les principaux de sécurité externes ne peuvent pas être membres de groupes universels.
'Error 8550 'L’attribut n’est pas autorisé à être répliqué sur le catalogue global pour des raisons de sécurité.
'Error 8551 'Le point de contrôle avec le PDC n’a pas pu être pris car trop de modifications sont en cours de traitement.
'Error 8552 'L’opération nécessite que l’audit du domaine source soit activé.
'Error 8553 'Les objets principaux de sécurité ne peuvent être créés que dans des contextes de nommage de domaines.
'Error 8554 'Un SPN (nom de principal du service) n’a pas pu être construit parce que le nom d’hôte fourni n’est pas dans le format nécessaire.
'Error 8555 'Un filtre qui utilise des attributs construits a été passé.
'Error 8556 'La valeur de l’attribut unicodePwd doit se trouver entre guillemets.
'Error 8557 'Votre ordinateur n’a pas pu joindre le domaine. Vous avez dépassé le nombre maximal de comptes d’ordinateur que vous êtes autorisé à créer dans ce domaine. Contactez votre administrateur système pour que cette limite soit réinitialisée ou augmentée.
'Error 8558 'Pour des raisons de sécurité, l’opération doit être exécutée sur le contrôleur de domaine destination.
'Error 8559 'Pour des raisons de sécurité, le contrôleur de domaine source doit exécuter NT4SP4 ou ultérieur.
'Error 8560 'Les objets du service d’annuaire critiques ne peuvent pas être supprimé lors des opérations de suppression d’arbre. La suppression de l’arborescence a peut-être été effectuée de manière partielle.
'Error 8561 'Les services d’annuaire n’ont pas pu démarrer en raison de l’erreur suivante  '%1. Statut de l’erreur  '0x%2. Cliquez sur OK pour arrêter le système. Vous pouvez utiliser la console de récupération pour effectuer un diagnostic minutieux du système.
'Error 8562 'L’initialisation du gestionnaire de comptes de sécurité a échoué en raison de l’erreur suivante  '%1. Statut de l’erreur  '0x%2. Cliquez sur OK pour arrêter le système. Vous pouvez utiliser la console de récupération pour diagnostiquer le système davantage.
'Error 8563 'La version du système d’exploitation n’est pas compatible avec le niveau fonctionnel de la forêt AD DS actuelle ou du jeu de configuration AD LDS. Vous devez procéder à une mise à niveau vers une nouvelle version du système d’exploitation pour que ce serveur p
'Error 8564 'La version du système d’exploitation installée n’est pas compatible  avec le niveau fonctionnel actuel du domaine. Vous devez mettre à niveau vers une nouvelle version du système d’exploitation pour que ce serveur puisse devenir un contrôleur de domaine dans c
'Error 8565 'La version du système d’exploitation installé sur ce serveur ne prend plus en charge le niveau fonctionnel de la forêt AD DS actuelle ou du jeu de configuration AD LDS. Vous devez élever le niveau fonctionnel de la forêt AD DS ou du jeu de configuration AD LDS
'Error 8566 'La version du système d’exploitation installée sur ce serveur ne prend plus en charge le niveau fonctionnel actuel du domaine. Vous devez augmenter le niveau fonctionnel du domaine pour que ce serveur puisse devenir un contrôleur de domaine dans ce domaine.
'Error 8567 'La version du système d’exploitation installée sur ce serveur n’est pas compatible avec le niveau fonctionnel du domaine ou de la forêt.
'Error 8568 'Le niveau fonctionnel du domaine (ou de la forêt) ne peut pas être augmenté à la valeur demandée car un ou plusieurs contrôleurs de domaine de niveau fonctionnel inférieur non compatible existent dans le domaine (ou la forêt).
'Error 8569 'Le niveau fonctionnel de la forêt ne peut pas être augmenté à la valeur demandée car un ou plusieurs domaines sont encore en mode de domaine mixte. Tous les domaines dans la forêt doivent être en mode natif afin que vous puissiez augmenter le niveau fonctionne
'Error 8570 'L’ordre de tri nécessaire n’est pas pris en charge.
'Error 8571 'Le nom unique existe déjà en tant qu’identificateur unique.
'Error 8572 'Le compte de l’ordinateur a été crée avant NT4. Le compte doit être crée à nouveau.
'Error 8573 'La base de données n’a plus de magasin de version.
'Error 8574 'Impossible de continuer l’opération car des contrôles multiples en conflit étaient utilisés.
'Error 8575 'Impossible de trouver un domaine de référence de descripteur de sécurité valide pour cette partition.
'Error 8576 'La mise à jour du schéma a échoué  'l’identificateur de liaison est réservé.
'Error 8577 'La mise à jour du schéma a échoué  'il n’y a pas d’identificateur de liaison disponible.
'Error 8578 'Un groupe de comptes ne peut pas avoir un groupe universel comme membre.
'Error 8579 'Les opérations de renommage ou de déplacement sur les têtes de contexte de nommage ou les objets en lecture seule ne sont pas autorisées.
'Error 8580 'Les opérations de déplacement sur les objets dans le contexte de nommage de schéma ne sont pas autorisées.
'Error 8581 'Un indicateur système a été placé sur l’objet et ne permet pas que l’objet soit déplacé ou renommé.
'Error 8582 'Cet objet n’est pas autorisé à modifier son conteneur grand-parent. Les déplacements ne sont pas interdits pour cet objet, mais ils sont restreint aux conteneurs frères.
'Error 8583 'Impossible de générer complètement, une référence à une autre forêt est généré.
'Error 8584 'L’action requise n’est pas prise en charge sur un serveur standard.
'Error 8585 'Impossible d’accéder à une partition du service d’annuaire situé sur un serveur distant. Vérifiez qu’au moins un serveur est en cours d’exécution pour la partition en question.
'Error 8586 'Le répertoire ne peut pas valider le nom du contexte de nommage proposé (ou de la partition) car il ne contient pas de réplica ni ne peut se mettre en rapport avec un réplica du contexte de nommage au-delà du contexte de nommage proposé. Assurez-vous que le co
'Error 8587 'La limite du thread de cette requête a été dépassée.
'Error 8588 'Le serveur de catalogue global n’est pas sur le site le plus proche.
'Error 8589 'Le DS ne peut pas dériver un nom de principal du service (SPN) avec lequel authentifier mutuellement le serveur cible car l’objet serveur correspondant dans la base de données locale DNS ne possède pas l’attribut Référence du serveur .
'Error 8590 'Le service d’annuaire n’a pas pu entrer en mode utilisateur simple.
'Error 8591 'Le service d’annuaire n’a pas pu analyser le script à cause d’une erreur de syntaxe.
'Error 8592 'Le service d’annuaire n’a pas pu traiter le script à cause d’une erreur.
'Error 8593 'Le service d’annuaire ne peut pas effectuer l’opération requise car les serveurs impliqués sont caractérisés par des époques de réplication différentes (phénomène généralement lié à une modification du nom du domaine en cours).
'Error 8594 'La liaison du service d’annuaire doit être négociée à nouveau à cause d’une modification des informations d’extensions du serveur.
'Error 8595 'L’opération n’est pas autorisée sur une référence croisée désactivée.
'Error 8596 'Échec de la mise à jour de schéma  'aucune valeur n’est disponible pour msDS-IntId.
'Error 8597 'Échec de la mise à jour de schéma  'msDS-INtId dupliquée. Essayez à nouveau l’opération.
'Error 8598 'Échec de la suppression de schéma  'un attribut est utilisé dans rDNAttID.
'Error 8599 'Le service d’annuaire n’a pas pu autoriser la requête.
'Error 8600 'Le service d’annuaire ne peut pas traiter le script car il n’est pas valide.
'Error 8601 'L’opération de référence croisée de création à distance a échoué sur le maître d’attribution de noms de domaine FSMO. L’erreur de l’opération est dans les données étendues.
'Error 8602 'Une référence croisée est en cours d’utilisation localement avec le même nom.
'Error 8603 'Le DS ne peut pas dériver un nom de principal du service (SPN) avec lequel authentifier le serveur cible mutuellement car le domaine du serveur a été supprimé de la forêt.
'Error 8604 'Des Nc inscriptibles empêchent la rétrogradation de ce contrôleur de domaine.
'Error 8605 'L’objet demandé a un identificateur qui n’est pas unique et ne peut pas être récupéré.
'Error 8606 'Des attributs insuffisants ont été donné pour créer un objet. Cet objet n’existe peut-être pas car il a été supprimé et récupéré.
'Error 8607 'Le groupe ne peut pas être converti en raison de restrictions d’attributs sur le type de groupe demandé.
'Error 8608 'Le déplacement entre domaines de groupes d’applications de base n’étant pas vide n’est pas autorisé.
'Error 8609 'Le déplacement entre domaines de groupes d’applications effectuant des requêtes n’est pas autorisé.
'Error 8610 'L’appartenance du rôle FSMO n’a pas pu être vérifiée car la partition du répertoire n’a pas été répliquée correctement avec au moins un partenaire de réplication.
'Error 8611 'Le conteneur cible pour la redirection d’un conteneur d’objet connu ne peut pas être déjà un conteneur spécial.
'Error 8612 'Le service d’annuaire ne peut pas effectuer l’opération requise car une opération de renommage du domaine est en cours.
'Error 8613 'Le service d’annuaire a détecté une partition enfant sous la partition demandée. La hiérarchie de partitions doit être créée selon une méthode de haut en bas.
'Error 8614 'Le service d’annuaire ne peut pas répliquer ce serveur car la durée de vie de désactivation depuis la dernière réplication de ce serveur a été dépassée.
'Error 8615 'L’opération demandée n’est pas autorisée sur un objet sous le conteneur système.
'Error 8616 'La file d’envoi réseau des serveurs LDAP a été remplie car le client ne traite pas les résultats de ses demandes assez rapidement. Aucune autre demande ne sera traitée tant que le client ne rattrapera pas son retard. Si le client n’y arrive pas, il sera déconn
'Error 8617 'La réplication planifiée n’a pas eu lieu car le système était trop occupé pour exécuter la requête dans l’intervalle de planification.  La file de réplication est surchargée. Réduisez éventuellement le nombre de partenaires ou réduisez la fréquence de réplicat
'Error 8618 'Il n’est actuellement pas possible de déterminer si la stratégie de réplication de branche est disponible sur le contrôleur de domaine du concentrateur. Réessayez ultérieurement pour prendre en compte les latences de réplication.
'Error 8619 'L’objet paramètres de site pour le site spécifié n’existe pas.
'Error 8620 'Le magasin de comptes local ne contient pas de documents secrets pour le compte spécifié.
'Error 8621 'Impossible de trouver un contrôleur de domaine accessible en écriture dans le domaine.
'Error 8622 'L’objet serveur pour le contrôleur de domaine n’existe pas.
'Error 8623 'L’objet paramètres NTDS pour le contrôleur de domaine n’existe pas.
'Error 8624 'L’opération de recherche demandée n’est pas prise en charge pour les recherches ASQ.
'Error 8625 'Impossible de générer un événement d’audit requis pour l’opération.
'Error 8626 'Indicateurs de recherche de l’attribut non valides. Le bit d’index de sous-arborescence est valide uniquement pour les attributs à valeur simple.
'Error 8627 'Balises de recherche de l’attribut non valides. Le bit d’index de tuple est valide uniquement pour les attributs de chaînes Unicode.
'Error 8628 'Les carnets d’adresses sont imbriqués trop profondément. Échec de la construction de la table de hiérarchie.
'Error 8629 'Le vecteur d’état de mise à jour spécifié est endommagé.
'Error 8630 'La demande de réplication des secrets est refusée.
'Error 8631 'Échec de la mise à jour du schéma  'l’identificateur MAPI est réservé.
'Error 8632 'Échec de la mise à jour du schéma  'aucun identificateur MAPI n’est disponible.
'Error 8633 'L’opération de réplication a échoué, car les attributs obligatoires de l’objet krbtgt local sont manquants.
'Error 8634 'Le nom de domaine du domaine approuvé existe déjà dans la forêt.
'Error 8635 'Le nom plat du domaine approuvé existe déjà dans la forêt.
'Error 8636 'Le nom d’utilisateur principal (UPN) n’est pas valide.
'Error 8637 'Les groupes mappés d’identificateur d’objet ne peuvent pas posséder de membres.
'Error 8638 'L’identificateur d’objet spécifié est introuvable.
'Error 8639 'L’opération de réplication a échoué car l’objet cible référencé par une valeur de lien est recyclé.
'Error 8640 'Échec de l’opération de redirection car l’objet cible se trouve dans un NC différent du NC de domaine du contrôleur de domaine actuel.
'Error 8641 'Impossible d’abaisser le niveau fonctionnel du jeu de configuration AD LDS à la valeur demandée.
'Error 8642 'Impossible d’abaisser le niveau fonctionnel du domaine (ou de la forêt) à la valeur demandée.
'Error 8643 'Impossible d’augmenter le niveau fonctionnel du jeu de configuration AD LDS à la valeur demandée, car une ou plusieurs instances d’ADLDS sont à un niveau fonctionnel inférieur incompatible.
'Error 8644 'Impossible d’effectuer la jonction de domaine car le SID du domaine que vous avez tenté de joindre était identique au SID de cet ordinateur. Cela est un symptôme d’une installation de système d’exploitation incorrectement clonée. Vous devez exécuter sysprep su
'Error 8645 'Échec d’une opération d’annulation de suppression car le nom de compte SAM ou le nom de compte SAM supplémentaire de l’objet dont la suppression est annulée est en conflit avec un objet actif existant.
'Error 8646 'Le système ne fait pas autorité pour le compte spécifié et ne peut donc pas mener à bien l’opération. Recommencez l’opération en utilisant le fournisseur associé à ce compte. S’il s’agit d’un fournisseur en ligne, utilisez le site en ligne du fournisseur.
'Error 8647 'Échec de l’opération, car la valeur SPN fournie pour l’ajout/la modification n’est pas unique à l’échelle de la forêt.
'Error 8648 'Échec de l’opération, car la valeur UPN fournie pour l’ajout/la modification n’est pas unique à l’échelle de la forêt.
'Error 8649 'Échec de l'opération, car l'ajout/la modification a référencé une approbation entrante à l'échelle de la forêt qui n'est pas présente.
'Error 8650 'La valeur de lien spécifiée était introuvable, mais une valeur de lien avec cette clé a été trouvée.
'Error 9001 'Le serveur DNS ne peut pas interpréter le format.
'Error 9002 'Défaillance du serveur DNS.
'Error 9003 'Le nom DNS n’existe pas.
'Error 9004 'La requête DNS n’est pas prise en charge par le serveur de noms.
'Error 9005 'Opération DNS refusée.
'Error 9006 'Présence d’un nom DNS qui ne devrait pas exister.
'Error 9007 'Présence d’un jeu de RR DNS qui ne devrait pas exister.
'Error 9008 'Impossible de trouver un jeu de RR DNS qui devrait exister.
'Error 9009 'Le serveur DNS ne fait pas autorité pour la zone.
'Error 9010 'Nom DNS de mise à jour ou prérequis introuvable dans la zone.
'Error 9016 'Échec de la vérification de la signature DNS.
'Error 9017 'Clé DNS incorrecte.
'Error 9018 'La validité de la signature DNS a expiré.
'Error 9101 'Seul le serveur DNS jouant le rôle de maître des clés pour la zone peut effectuer cette opération.
'Error 9102 'Cette opération n’est pas autorisée sur une zone signée ou comportant des clés de signature.
'Error 9103 'NSEC3 n’est pas compatible avec l’algorithme RSA-SHA-1. Sélectionnez un autre algorithme ou utilisez NSEC.
'Error 9104 'La zone n’a pas suffisamment de clés de signature. Il doit y avoir au moins une clé de signature de clé (KSK) et au moins une clé de signature de zone (ZSK).
'Error 9105 'L’algorithme spécifié n’est pas pris en charge.
'Error 9106 'La taille de clé spécifiée n’est pas prise en charge.
'Error 9107 'Une ou plusieurs des clés de signature pour une zone ne sont pas accessibles au serveur DNS. La signature de zone ne sera opérationnelle qu’une fois cette erreur résolue.
'Error 9108 'Le fournisseur de stockage de clé spécifié ne prend pas en charge la protection de données DPAPI++. La signature de zone ne sera opérationnelle qu’une fois cette erreur résolue.
'Error 9109 'Une erreur DPAPI++ inattendue s’est produite. La signature de zone ne sera opérationnelle qu’une fois cette erreur résolue.
'Error 9110 'Une erreur de chiffrement inattendue s’est produite. La signature de zone ne sera opérationnelle qu’une fois cette erreur résolue.
'Error 9111 'Le serveur DNS a rencontré une clé de signature avec une version inconnue. La signature de zone ne sera opérationnelle qu’une fois cette erreur résolue.
'Error 9112 'Le fournisseur de services de clés spécifié ne peut pas être ouvert par le serveur DNS.
'Error 9113 'Le serveur DNS ne peut plus accepter de clés de signature avec l’algorithme et la valeur d’indicateur de clé KSK spécifiés pour cette zone.
'Error 9114 'La période de régénération spécifiée n’est pas valide.
'Error 9115 'Le décalage de la régénération initiale spécifié n’est pas valide.
'Error 9116 'La clé de signature spécifiée est déjà en cours de régénération de clés.
'Error 9117 'La clé de signature spécifiée n’a pas de clé de secours à révoquer.
'Error 9118 'Cette opération n’est pas autorisée sur une clé de signature de zone (ZSK).
'Error 9119 'Cette opération n’est pas autorisée sur une clé de signature active.
'Error 9120 'La clé de signature spécifiée est déjà placée en file d’attente pour la régénération.
'Error 9121 'Cette opération n’est pas autorisée sur une zone non signée.
'Error 9122 'Impossible de terminer cette opération, car le serveur DNS répertorié en tant que maître des clés actuel pour cette zone est hors service ou mal configuré. Corrigez le problème sur le maître des clés actuel pour cette zone ou affectez le rôle de maître des clé
'Error 9123 'La période de validité de la signature spécifiée n’est pas valide.
'Error 9124 'Le nombre d’itérations NSEC3 spécifié est supérieur à celui autorisé par la longueur de clé minimale utilisée dans la zone.
'Error 9125 'Impossible de terminer cette opération car le serveur DNS a été configuré avec les fonctionnalités DNSSEC désactivées. Activez DNSSEC sur le serveur DNS.
'Error 9126 'Impossible de terminer cette opération, car le flux XML reçu est vide ou sa syntaxe n’est pas valide.
'Error 9127 'Cette opération s’est terminée, mais aucune ancre d’approbation n’a été ajoutée, car l’ensemble des ancres d’approbation reçues étaient non valides, non prises en charge, avaient expiré ou ne deviendraient pas valides d’ici 30 jours.
'Error 9128 'La clé de signature spécifiée n’attend pas de mise à jour DS parentale.
'Error 9129 'Collision de hachage détectée au cours de la signature NSEC3. Spécifiez un autre sel fourni par l’utilisateur ou utilisez un sel généré aléatoirement, puis essayez de resigner la zone.
'Error 9130 'NSEC n’est pas compatible avec l’algorithme NSEC3-RSA-SHA-1. Sélectionnez un autre algorithme ou utilisez NSEC3.
'Error 9501 'Aucun enregistrement trouvé pour la requête DNS donnée.
'Error 9502 'Paquet DNS incorrect.
'Error 9503 'Aucun paquet DNS.
'Error 9504 'Erreur DNS, vérifiez le rcode.
'Error 9505 'Paquet DNS non sécurisé.
'Error 9506 'Une demande de requête DNS est en attente.
'Error 9551 'Type DNS non valide.
'Error 9552 'Adresse IP non valide.
'Error 9553 'Propriété non valide.
'Error 9554 'Réessayez l’opération DNS ultérieurement.
'Error 9555 'Il existe plusieurs enregistrements pour le nom et le type donnés.
'Error 9556 'Le nom DNS n’est pas conforme aux spécifications RFC.
'Error 9557 'Le nom DNS répond à tous les critères.
'Error 9558 'Le nom DNS est séparé par des points (appellations multiples).
'Error 9559 'Le nom DNS est un nom de partie unique.
'Error 9560 'Le nom DNS contient un caractère non valide.
'Error 9561 'Le nom DNS est composé uniquement de chiffres.
'Error 9562 'L’opération requise n’est pas autorisée sur un serveur racine DNS.
'Error 9563 'L’enregistrement n’a pas pu être crée car cette partie de l’espace de nom DNS a été déléguée à un autre serveur.
'Error 9564 'Le serveur DNS n’a pas pu trouver un jeu d’indications de racine.
'Error 9565 'Le serveur DNS a trouvé des indications de racine mais elles n’étaient pas consistantes sur toutes les cartes.
'Error 9566 'La valeur spécifiée est trop petite pour ce paramètre.
'Error 9567 'La valeur spécifiée est trop grande pour ce paramètre.
'Error 9568 'Cette opération n’est pas autorisée pendant que le serveur DNS charge des zones en arrière-plan. Réessayez ultérieurement.
'Error 9569 'L’opération demandée n’est pas autorisée sur un serveur DNS exécuté sur un contrôleur de domaine en lecture seule.
'Error 9570 'Les données ne sont pas autorisées sous un enregistrement DNAME.
'Error 9571 'Cette opération nécessite la délégation des informations d’identification.
'Error 9572 'La table de stratégie de résolution des noms a été endommagée. La résolution DNS échouera tant que le problème ne sera pas résolu. Contactez votre administrateur réseau.
'Error 9573 'La suppression de toutes les adresses n'est pas autorisée.
'Error 9601 'La zone DNS n’existe pas.
'Error 9602 'Les informations sur la zone DNS ne sont pas disponibles.
'Error 9603 'Opération non valide pour la zone DNS.
'Error 9604 'Configuration d’une zone DNS non valide.
'Error 9605 'La zone DNS n’a pas d’enregistrement de source de noms (SOA).
'Error 9606 'La zone DNS n’a pas d’enregistrement de serveur de noms (NS).
'Error 9607 'La zone DNS est verrouillée.
'Error 9608 'Échec de la création d’une zone DNS.
'Error 9609 'La zone DNS existe déjà.
'Error 9610 'La zone automatique DNS existe déjà.
'Error 9611 'Type de zone DNS non valide.
'Error 9612 'La zone DNS secondaire nécessite une adresse IP principale.
'Error 9613 'La zone DNS n’est pas secondaire.
'Error 9614 'Adresse IP secondaire requise.
'Error 9615 'Échec de l’initialisation de WINS.
'Error 9616 'Serveurs WINS nécessaires.
'Error 9617 'Échec de l’appel de l’initialisation de NBTSTAT.
'Error 9618 'Suppression non valide d’une source de noms (SOA)
'Error 9619 'Une zone de transfert conditionnelle existe déjà pour ce nom.
'Error 9620 'Cette zone doit être configurée avec une ou plusieurs adresses IP de serveur DNS maître.
'Error 9621 'Impossible d’effectuer l’opération, car cette zone est fermée.
'Error 9622 'Cette opération ne peut pas être effectuée car la zone est en cours de signature. Réessayez ultérieurement.
'Error 9651 'La zone DNS principale nécessite un fichier de données.
'Error 9652 'Fichier de données non valide pour la zone DNS.
'Error 9653 'Échec de l’ouverture du fichier de donnée pour la zone DNS.
'Error 9654 'Échec de l’écriture du fichier de données pour la zone DNS.
'Error 9655 'Échec lors de la lecture du fichier de données pour la zone DNS.
'Error 9701 'L’enregistrement DNS n’existe pas.
'Error 9702 'Erreur dans le format d’enregistrement DNS.
'Error 9703 'Échec de création d’un nœud dans le DNS.
'Error 9704 'Type d’enregistrement DNS inconnu.
'Error 9705 'Délai d’enregistrement DNS dépassé.
'Error 9706 'Le nom ne se trouve pas dans la zone DNS.
'Error 9707 'Une boucle CNAME a été détectée.
'Error 9708 'Le nœud est un enregistrement DNS CNAME.
'Error 9709 'Un enregistrement CNAME existe déjà pour le nom donné.
'Error 9710 'Enregistrer uniquement à la racine de la zone DNS.
'Error 9711 'L’enregistrement DNS existe déjà.
'Error 9712 'Erreur de données dans la zone DNS secondaire.
'Error 9713 'Impossible de créer des données caches DNS.
'Error 9714 'Le nom DNS n’existe pas.
'Error 9715 'Impossible de créer un enregistrement de pointeurs (PRT).
'Error 9716 'Le domaine DNS a été récupéré.
'Error 9717 'Le service d’annuaire n’est pas disponible.
'Error 9718 'La zone DNS existe déjà dans Active Directory.
'Error 9719 'Le serveur DNS n’est pas en cours de création ou de lecture du fichier de démarrage de la zone DNS qui comprend un Active Directory.
'Error 9720 'Le nœud est un enregistrement DNS DNAME.
'Error 9721 'Un enregistrement DNAME existe déjà pour le nom donné.
'Error 9722 'Une boucle d’alias a été détectée avec des enregistrements CNAME ou DNAME.
'Error 9751 'Transfert de zone (DNS AXFR) terminé.
'Error 9752 'Le transfert de la zone DNS a échoué.
'Error 9753 'Ajout d’un serveur local WINS.
'Error 9801 'L’appel à une mise à jour sécurisée doit continuer la demande de mise à jour.
'Error 9851 'Le protocole réseau TCP/IP n’est pas installé.
'Error 9852 'Aucun serveur DNS n’est configuré pour le système local.
'Error 9901 'La partition du répertoire spécifiée n’existe pas.
'Error 9902 'La partition du répertoire spécifié existe déjà.
'Error 9903 'Ce serveur DNS  n’est pas enrôlé dans la partition du répertoire spécifié.
'Error 9904 'Ce serveur DNS est déjà enrôlé dans la partition du répertoire spécifié.
'Error 9905 'La partition de répertoire n’est pas disponible en ce moment. Veuillez patienter quelques minutes et essayez à nouveau.
'Error 9906 'L’opération a échoué car le rôle FSMO de maître d’opérations des noms de domaine est inaccessible. Le contrôleur de domaine tenant le rôle FSMO de maître d’opérations des noms de domaine est éteint, ne peut pas répondre à la demande ou ne fonctionne pas sous W
'Error 9911 'La RRL n'est pas activée.
'Error 9912 'Le paramètre de taille de fenêtre n'est pas valide. Il doit être supérieur ou égal à 1.
'Error 9913 'Le paramètre de longueur de préfixe IPv4 n'est pas valide. Il doit être inférieur ou égal à 32.
'Error 9914 'Le paramètre de longueur du préfixe IPv6 n'est pas valide. Il doit être inférieur ou égal à 128.
'Error 9915 'Le paramètre de taux de TC n'est pas valide. Il doit être inférieur à 10.
'Error 9916 'Le paramètre de taux de fuite n'est pas valide. Il doit être égal à 0, ou être compris entre 2 et 10.
'Error 9917 'Le paramètre de taux de fuite ou de TC n'est pas valide. Le taux de fuite doit être supérieur au taux de TC.
'Error 9921 'Cette instance de virtualisation existe déjà.
'Error 9922 'Cette instance de virtualisation n’existe pas.
'Error 9923 'Cette arborescence de virtualisation est verrouillée.
'Error 9924 'Nom d’instance de virtualisation non valide.
'Error 9925 'Impossible d’ajouter, de supprimer ou de modifier l’instance de virtualisation par défaut.
'Error 9951 'L’étendue existe déjà pour la zone.
'Error 9952 'L’étendue n’existe pas pour la zone.
'Error 9953 'L’étendue est la même que l’étendue de la zone par défaut.
'Error 9954 'Le nom de l’étendue contient des caractères non valides.
'Error 9955 'Opération non autorisée quand la zone dispose d’étendues.
'Error 9956 'Échec du chargement de l’étendue de la zone.
'Error 9957 'Échec de l’écriture du fichier de données pour l’étendue de la zone DNS. Vérifiez si le fichier existe et est accessible en écriture.
'Error 9958 'Le nom de l’étendue contient des caractères non valides.
'Error 9959 'L’étendue n’existe pas.
'Error 9960 'L’étendue est la même que l’étendue par défaut.
'Error 9961 'L’opération n’est pas valide dans l’étendue.
'Error 9962 'L’étendue est verrouillée.
'Error 9963 'L’étendue existe déjà.
'Error 9971 'Une stratégie du même nom existe déjà à ce niveau (niveau serveur ou niveau zone) sur le serveur DNS.
'Error 9972 'Aucune stratégie de ce nom n'existe à ce niveau (niveau serveur ou niveau zone) sur le serveur DNS.
'Error 9973 'Les critères fournis dans la stratégie ne sont pas valides.
'Error 9974 'L 'un des paramètres au moins de cette stratégie n'est pas valide.
'Error 9975 'Impossible de supprimer le sous-réseau du client pendant qu'une stratégie est en train d'y accéder.
'Error 9976 'Le sous-réseau du client n'existe pas sur le serveur DNS.
'Error 9977 'Un sous-réseau de client du même nom existe déjà sur le serveur DNS.
'Error 9978 'Le sous-réseau IP indiqué n'existe pas dans le sous-réseau du client.
'Error 9979 'Le sous-réseau IP en cours d'ajout existe déjà dans le sous-réseau du client.
'Error 9980 'La stratégie est verrouillée.
'Error 9981 'Le poids de l'étendue de la stratégie n'est pas valide.
'Error 9982 'Le nom DNS de stratégie n'est pas valide.
'Error 9983 'Il manque des critères à la stratégie.
'Error 9984 'Le nom d'enregistrement du sous-réseau client n'est pas valide.
'Error 9985 'L 'ordre de traitement de stratégie n'est pas valide .
'Error 9986 'Les informations d'étendue n'ont pas été fournies pour une stratégie qui requiert ces données.
'Error 9987 'Les informations d'étendue ont été fournies pour une stratégie qui ne requiert pas ces données.
'Error 9988 'Impossible de supprimer la portée du serveur, car elle est référencée par une stratégie DNS.
'Error 9989 'Impossible de supprimer la portée de la zone, car elle est référencée par une stratégie DNS.
'Error 9990 'Le critère sous-réseau du client indiqué dans la stratégie n'est pas valide.
'Error 9991 'Le critère protocole de transport indiqué dans la stratégie n'est pas valide.
'Error 9992 'Le critère protocole réseau indiqué dans la stratégie n'est pas valide.
'Error 9993 'Le critère interface indiqué dans la stratégie n'est pas valide.
'Error 9994 'Le critère FQDN (nom de domaine complet) indiqué dans la stratégie n'est pas valide.
'Error 9995 'Le critère type de requête indiqué dans la stratégie n'est pas valide.
'Error 9996 'Le critère heure courante indiqué dans la stratégie n'est pas valide.
'Error 10004 'Une opération de blocage a été interrompue par un appel à WSACancelBlockingCall.
'Error 10009 'Le descripteur de fichier fourni n’est pas valide.
'Error 10013 'Une tentative d’accès à un socket de manière interdite par ses autorisations d’accès a été tentée.
'Error 10014 'Le système a détecté une adresse de pointeur non valide en essayant d’utiliser un argument pointeur dans un appel.
'Error 10022 'Un argument non valide a été fourni.
'Error 10024 'Trop de sockets ouverts.
'Error 10035 'Une opération non bloquante sur un socket n’a pas pu être achevée immédiatement.
'Error 10036 'Une opération de blocage est en cours d’exécution.
'Error 10037 'Une opération a été tentée sur un socket non bloquant qui avait déjà une opération en cours.
'Error 10038 'Une opération a été tentée sur autre chose qu’un socket.
'Error 10039 'Une adresse nécessaire a été omise d’une opération sur un socket.
'Error 10040 'Un message envoyé sur un socket datagramme était plus volumineux que le tampon de messages interne ou qu’une autre limite réseau ou bien le tampon utilisé pour recevoir un datagramme était plus petit que le datagramme lui-même.
'Error 10041 'Un protocole spécifié dans l’appel de fonction sur socket ne prend pas en charge la sémantique du type de socket requis.
'Error 10042 'Une option ou un niveau inconnu, non valide ou non pris en charge a été spécifié dans un appel getsockopt ou setsockopt.
'Error 10043 'Le protocole requis n’a pas été configuré dans le système ou aucune implémentation n’existe pour lui.
'Error 10044 'La prise en charge du type de socket spécifié n’existe pas dans cette famille d’adresses.
'Error 10045 'L’opération tentée n’est pas prise en charge pour le type d’objet référencé.
'Error 10046 'La famille de protocoles n’a pas été configurée dans le système ou aucune implémentation n’existe pour elle.
'Error 10047 'Une adresse incompatible avec le protocole demandé a été utilisée.
'Error 10048 'Une seule utilisation de chaque adresse de socket (protocole/adresse réseau/port) est habituellement autorisée.
'Error 10049 'L’adresse demandée n’est pas valide dans son contexte.
'Error 10050 'Une opération de socket a rencontré un réseau inactif.
'Error 10051 'Une opération a été tentée sur un réseau impossible à atteindre.
'Error 10052 'La connexion a été interrompue en raison d’un maintien d’activité ayant détecté un échec lorsque l’opération était en cours.
'Error 10053 'Une connexion établie a été abandonnée par un logiciel de votre ordinateur hôte.
'Error 10054 'Une connexion existante a dû être fermée par l’hôte distant.
'Error 10055 'Une opération sur un socket n’a pas pu être effectuée car le système ne disposait pas de suffisamment d’espace dans la mémoire tampon ou parce que la file d’attente était saturée.
'Error 10056 'Une demande de connexion a été effectuée sur un socket déjà connecté.
'Error 10057 'Une requête d’envoi ou de réception de données n’a pas été autorisée car le socket n’est pas connecté et (lors de l’envoi sur un socket datagramme en utilisant un appel sendto) aucune adresse n’a été fournie.
'Error 10058 'Une demande d’envoi ou de réception de données n’a pas été autorisée car le socket avait déjà été éteint dans cette direction par un appel d’arrêt précédent.
'Error 10059 'Trop de références à un objet du noyau.
'Error 10060 'Une tentative de connexion a échoué car le parti connecté n’a pas répondu convenablement au-delà d’une certaine durée ou une connexion établie a échoué car l’hôte de connexion n’a pas répondu.
'Error 10061 'Aucune connexion n’a pu être établie car l’ordinateur cible l’a expressément refusée.
'Error 10062 'Impossible de traduire le nom.
'Error 10063 'Un composant du nom ou le nom était trop long.
'Error 10064 'Une opération de socket a échoué car l’hôte de destination était en panne.
'Error 10065 'Une opération a été tentée sur un hôte impossible à atteindre.
'Error 10066 'Impossible de supprimer un répertoire qui n’est pas vide.
'Error 10067 'Une implémentation Windows Sockets peut avoir une limite sur le nombre d’applications pouvant l’utiliser simultanément.
'Error 10068 'Nombre de quotas insuffisant.
'Error 10069 'Nombre de quotas de disque insuffisant.
'Error 10070 'La référence au descripteur de fichier n’est plus disponible.
'Error 10071 'L’élément n’est pas disponible localement.
'Error 10091 'WSAStartup ne peut pas fonctionner actuellement car le système sous-jacent qu’il utilise pour fournir des services réseau n’est pas disponible pour le moment.
'Error 10092 'La version de Windows Sockets demandée n’est pas prise en charge.
'Error 10093 'Soit l’application n’a pas appelé WSAStartup, soit WSAStartup a échoué.
'Error 10101 'Renvoyé par WSARecv ou WSARecvFrom pour indiquer que le parti distant a démarré une séquence d’arrêt appropriée.
'Error 10102 'Aucun autre résultat ne peut être envoyé par WSALookupServiceNext.
'Error 10103 'Un appel à WSALookupServiceEnd a été effectué pendant que cet appel était en cours de traitement. L’appel a été annulé.
'Error 10104 'La table d’appels de procédures n’est pas valide.
'Error 10105 'Le fournisseur de services demandé n’est pas valide.
'Error 10106 'Le fournisseur de services demandé n’a pas pu être chargé ou initialisé.
'Error 10107 'Un appel système a échoué.
'Error 10108 'Ce service n’est pas connu. Impossible de trouver le service dans l’espace nom spécifié.
'Error 10109 'Impossible de trouver la classe spécifiée.
'Error 10110 'Aucun autre résultat ne peut être envoyé par WSALookupServiceNext.
'Error 10111 'Un appel à WSALookupServiceEnd a été effectué pendant que cet appel était en cours de traitement. L’appel a été annulé.
'Error 10112 'Une requête de base de données a échoué car elle a été refusée de manière active.
'Error 11001 'Hôte inconnu.
'Error 11002 'Ceci est habituellement une erreur temporaire qui se produit durant la résolution du nom d’hôte et qui signifie que le serveur local n’a pas reçu de réponse d’un serveur faisant autorité.
'Error 11003 'Une erreur irrécupérable s’est produite lors d’une recherche sur la base de données.
'Error 11004 'Le nom demandé est valide, mais aucune donnée du type requise n’a été trouvée.
'Error 11005 'Au moins une réserve est arrivée.
'Error 11006 'Au moins un chemin d’accès est arrivé.
'Error 11007 'Il n’y a pas d’émetteurs.
'Error 11008 'Il n’y a pas de récepteurs.
'Error 11009 'La réserve a été confirmée.
'Error 11010 'Erreur due à des ressources insuffisantes.
'Error 11011 'Rejeté pour raisons d’administration - informations d’identification incorrectes.
'Error 11012 'Style inconnu ou provoquant un conflit.
'Error 11013 'Problème avec une partie du filterspec ou avec l’ensemble du tampon providerspecific.
'Error 11014 'Problème avec une partie du flowspec.
'Error 11015 'Erreur QOS générale.
'Error 11016 'Un type de service non valide ou non reconnu a été trouvé dans le flowspec.
'Error 11017 'Un flowspec non valide ou incohérent a été trouvé dans la structure QOS.
'Error 11018 'Tampon QOS spécifique au fournisseur non valide.
'Error 11019 'Un style de filtre QOS non valide a été utilisé.
'Error 11020 'Un type de filtre QOS non valide a été utilisé.
'Error 11021 'Un nombre incorrect de FILTERSPEC QOS était spécifié FLOWDESCRIPTOR.
'Error 11022 'Un objet dont le champ ObjectLength est non valide a été spécifié dans le tampon QOS spécifique au fournisseur.
'Error 11023 'Un nombre incorrect de descripteurs de flux était spécifié dans la structure QOS.
'Error 11024 'Un objet non reconnu a été trouvé dans tampon QOS spécifique au fournisseur.
'Error 11025 'Un objet de stratégie non valide non reconnu a été trouvé dans le tampon QOS spécifique au fournisseur.
'Error 11026 'Un descripteur de flux QOS non valide a été trouvé dans la liste des descripteurs de flux.
'Error 11027 'Un flowspec non valide ou incohérent a été trouvé dans le tampon spécifique au fournisseur.
'Error 11028 'Un FILTERSPEC non valide a été trouvé dans le tampon QOS spécifique au fournisseur.
'Error 11029 'Un objet de mode de rejet des formes a été trouvé dans le tampon spécifique au fournisseur.
'Error 11030 'Un objet de taux de formation non valide non reconnu a été trouvé dans le tampon QOS spécifique au fournisseur.
'Error 11031 'Un élément de stratégie réservée non reconnu a été trouvé dans tampon QOS spécifique au fournisseur.
'Error 11032 'Aucun hôte de ce type n’est connu de façon sûre.
'Error 11033 'Impossible d’ajouter la stratégie IPSEC basée sur le nom.
'Error 13000 'La stratégie de mode rapide spécifiée existe déjà.
'Error 13001 'La stratégie de mode rapide spécifiée n’a pas été trouvée.
'Error 13002 'La stratégie de mode rapide spécifiée est en cours d’utilisation.
'Error 13003 'La stratégie de mode principal spécifiée existe déjà.
'Error 13004 'La stratégie de mode principal spécifiée n’a pas été trouvée.
'Error 13005 'La stratégie de mode principal spécifiée est en cours d’utilisation.
'Error 13006 'Le filtre de mode principal spécifié existe déjà.
'Error 13007 'Le filtre de mode principal spécifié n’a pas été trouvé.
'Error 13008 'Le filtre de mode de transport spécifié existe déjà.
'Error 13009 'Le filtre de mode de transport n’existe pas.
'Error 13010 'La liste d’authentification de mode principal spécifiée existe.
'Error 13011 'La liste d’authentification de mode principal spécifiée n’a pas été trouvée.
'Error 13012 'La liste d’authentification de mode principal spécifiée est en cours d’utilisation.
'Error 13013 'La stratégie de mode principal spécifiée par défaut est introuvable.
'Error 13014 'La liste d’authentification de mode principal spécifiée par défaut est introuvable.
'Error 13015 'Stratégie de mode rapide par défaut spécifiée introuvable.
'Error 13016 'Le filtre du mode de tunnel spécifié existe.
'Error 13017 'Filtre du mode de tunnel spécifié introuvable.
'Error 13018 'Le filtre de mode principal est en attente de suppression.
'Error 13019 'Le filtre de transport est en attente de suppression.
'Error 13020 'Le filtre tunnel est en attente de suppression.
'Error 13021 'La stratégie de mode principal est en attente de suppression.
'Error 13022 'Le groupement d’authentification de mode principal est en attente de suppression.
'Error 13023 'La stratégie de mode rapide est en attente de suppression.
'Error 13024 'La stratégie de mode principal a été ajoutée avec succès mais certaines des offres requises ne sont pas prises en charge.
'Error 13025 'La stratégie Mode rapide a été ajoutée avec succès mais certaines des offres requises ne sont pas prises en charge.
'Error 13800 'ERROR_IPSEC_IKE_NEG_STATUS_BEGIN
'Error 13801 'Les informations d’authentification IKE ne sont pas acceptables
'Error 13802 'Les attributs de sécurité IKE ne sont pas acceptables
'Error 13803 'Négociation IKE en cours
'Error 13804 'Erreur de traitement générale
'Error 13805 'Le délai d’attente a expiré pour la négociation
'Error 13806 'Échec du service IKE pour trouver un certificat d’ordinateur valide. Pour plus d’informations sur l’installation d’un certificat valide dans le magasin de certificats approprié, contactez votre administrateur de sécurité réseau.
'Error 13807 'SA IKE supprimée par l’homologue avant que l’établissement ait été terminé
'Error 13808 'SA IKE supprimée avant que l’établissement ait été terminé
'Error 13809 'La demande de négociation est restée trop longtemps en file d’attente
'Error 13810 'La demande de négociation est restée trop longtemps en file d’attente
'Error 13811 'La demande de négociation est restée trop longtemps en file d’attente
'Error 13812 'La demande de négociation est restée trop longtemps en file d’attente
'Error 13813 'Pas de réponse de l’homologue
'Error 13814 'La négociation a pris trop de temps
'Error 13815 'La négociation a pris trop de temps
'Error 13816 'Une erreur inconnue s’est produite
'Error 13817 'Le contrôle de révocation de certificat a échoué
'Error 13818 'Utilisation de clé de certificat non valide
'Error 13819 'Type de certificat non valide
'Error 13820 'Échec de la négociation IKE car le certificat d’ordinateur utilisé n’a pas de clé privée. Les certificats IPSec nécessitent une clé privée. Pour plus d’informations sur le remplacement du certificat existant par un certificat doté d’une clé privée, contactez v
'Error 13821 'Des renouvellements simultanés de demande de saisie de clé/mot de passe ont été détectés.
'Error 13822 'Échec dans le traitement Diffie-Hellman
'Error 13823 'Méthode de traitement de la charge utile critique non déterminée
'Error 13824 'En-tête non valide
'Error 13825 'Aucune stratégie configurée
'Error 13826 'Échec de la vérification de la signature
'Error 13827 'Échec de l’authentification à l’aide de Kerberos
'Error 13828 'Le certificat de l’homologue n’a pas de clé publique
'Error 13829 'Erreur dans le traitement de la charge utile d’erreur
'Error 13830 'Erreur dans le traitement de la charge utile du SA
'Error 13831 'Erreur dans le traitement de la charge utile de la proposition
'Error 13832 'Erreur dans le traitement de la charge utile de la transformation
'Error 13833 'Erreur dans le traitement de la charge utile du KE
'Error 13834 'Erreur dans le traitement de la charge utile de l’ID
'Error 13835 'Erreur dans le traitement de la charge utile du certificat
'Error 13836 'Erreur dans le traitement de la charge utile de la demande de certificat
'Error 13837 'Erreur dans le traitement de la charge utile de hachage
'Error 13838 'Erreur dans le traitement de la charge utile de la signature
'Error 13839 'Erreur dans le traitement de la charge utile créée pour la circonstance
'Error 13840 'Erreur dans le traitement de la charge utile de notification
'Error 13841 'Erreur dans le traitement de la charge utile de suppression
'Error 13842 'Erreur dans le traitement de la charge utile du VendorID
'Error 13843 'Charge utile non valide reçue
'Error 13844 'SA logicielle chargée
'Error 13845 'SA logicielle déchirée
'Error 13846 'Cookie non valide reçu.
'Error 13847 'L’homologue n’a pas envoyé un certificat d’ordinateur valide
'Error 13848 'La vérification de révocation de certificat pour le certificat de l’homologue a échoué
'Error 13849 'La nouvelle stratégie a invalidé les SA formés avec l’ancienne stratégie
'Error 13850 'Aucune stratégie IKE de mode rapide n’est disponible.
'Error 13851 'Impossible d’activer les privilèges TCB.
'Error 13852 'Impossible de charger SECURITY.DLL.
'Error 13853 'Impossible d’obtenir de SSPI les adresses de diffusion de la table de fonction de sécurité.
'Error 13854 'Impossible de demander au package Kerberos l’obtention de la taille maximum de jeton.
'Error 13855 'Impossible d’obtenir les informations d’identification du serveur Kerberos pour le service ISAKMP/ERROR_IPSEC_IKE. L’authentification Kerberos ne fonctionnera pas. La raison la plus probable de ce problème est l’absence d’appartenance à un domaine. Ceci est no
'Error 13856 'Impossible de déterminer le nom principal SSPI pour le service ISAKMP/ERROR_IPSEC_IKE (QueryCredentialsAttributes).
'Error 13857 'Impossible d’obtenir un nouveau SPI pour la SA entrante à partir du pilote IPsec. Le plus souvent, ce problème est dû au fait que le pilote ne dispose pas du filtre correct. Vérifiez les filtres dans votre stratégie.
'Error 13858 'Le filtre donné n’est pas valide
'Error 13859 'L’allocation de mémoire a échoué.
'Error 13860 'Impossible d’ajouter une association de sécurité au pilote IPsec. Le plus souvent, ce problème est dû au fait que la négociation IKE met trop de temps pour aboutir. Si ce problème persiste, diminuez la charge de l’ordinateur incriminé.
'Error 13861 'Stratégie non valide
'Error 13862 'DOI non valide
'Error 13863 'Situation non valide
'Error 13864 'Échec Diffie - Hellman
'Error 13865 'Groupe Diffie-Hellman non valide
'Error 13866 'Erreur lors du chiffrement de la charge utile
'Error 13867 'Erreur lors du déchiffrement de la charge utile
'Error 13868 'Erreur de correspondance de stratégie
'Error 13869 'ID non pris en charge
'Error 13870 'Échec de vérification du hachage
'Error 13871 'Algorithme de hachage non valide
'Error 13872 'Taille de hachage non valide
'Error 13873 'Algorithme de chiffrement non valide
'Error 13874 'Algorithme d’authentification non valide
'Error 13875 'Signature de certificat non valide
'Error 13876 'Échec du chargement
'Error 13877 'Supprimé via un appel RPC
'Error 13878 'Un état temporaire a été créé afin d’effectuer une réinitialisation. Il ne s’agit pas d’un échec réel.
'Error 13879 'La valeur de la durée de vie reçue dans la notification de durée de vie du répondeur est inférieure à la valeur minimale configurée par Windows. Corrigez cette stratégie sur l’ordinateur homologue.
'Error 13880 'Le destinataire ne peut pas gérer la version d’IKE spécifiée dans l’en-tête.
'Error 13881 'La longueur de la clé dans le certificat est trop petite pour les besoins de la sécurité configurée.
'Error 13882 'Le nombre maximal d’accès de sécurité MM établis vers les homologues a été dépassé.
'Error 13883 'IKE a reçu une stratégie qui désactive la négociation.
'Error 13884 'Limite maximale autorisée du mode rapide atteinte pour le mode principal. Un nouveau mode principal sera démarré.
'Error 13885 'La durée de vie de l’association de sécurité du mode principal a expiré ou l’homologue a envoyé une suppression du mode principal.
'Error 13886 'L’association de sécurité du mode principal est considérée comme non valide car l’homologue a cessé de répondre.
'Error 13887 'Le certificat n’est pas lié à une source digne de confiance dans la stratégie IPSec.
'Error 13888 'Réception d’un ID de message inattendu.
'Error 13889 'Réception de propositions d’authentification non valides.
'Error 13890 'Envoi d’une notification de cookie DoS à l’initiateur.
'Error 13891 'Service IKE en cours de fermeture.
'Error 13892 'Impossible de vérifier la liaison entre l’adresse et le certificat CGA.
'Error 13893 'Erreur de traitement de la charge utile NatOA.
'Error 13894 'Des paramètres du mode principal ne sont pas valides pour ce mode rapide.
'Error 13895 'L’association de sécurité du mode rapide a été refusée par le pilote IPSec.
'Error 13896 'Trop de filtres IKEEXT ajoutés dynamiquement ont été détectés.
'Error 13897 'ERROR_IPSEC_IKE_NEG_STATUS_END
'Error 13898 'La réauthentification NAP a abouti et doit supprimer le tunnel IKEv2 NAP factice.
'Error 13899 'Erreur lors de l’attribution d’une adresse IP interne à l’initiateur en mode tunnel.
'Error 13900 'Charge utile de configuration requise manquante.
'Error 13901 'Une négociation s’exécutant comme principe de sécurité à l’origine de la connexion est en cours.
'Error 13902 'SA a été supprimé suite à la vérification de la suppression de la coexistence d’IKEv1/AuthIP.
'Error 13903 'La demande SA entrante a été abandonnée en raison de la limitation du débit pour l’adresse IP de l’homologue.
'Error 13904 'L’homologue ne prend pas en charge MOBIKE.
'Error 13905 'L’établissement d’associations de sécurité n’est pas autorisé.
'Error 13906 'L’établissement d’associations de sécurité n’est pas autorisé car les informations d’identification PKINIT ne sont pas suffisamment fortes.
'Error 13907 'L’établissement d’associations de sécurité n’est pas autorisé.  Vous devrez peut-être entrer des informations d’identification mises à jour ou différentes comme une carte à puce.
'Error 13908 'L’établissement d’associations de sécurité n’est pas autorisé car les informations d’identification PKINIT ne sont pas suffisamment fortes. Ceci pourrait s’expliquer par l’échec du mappage de certificat à compte pour l’association de sécurité.
'Error 13909 'ERROR_IPSEC_IKE_NEG_STATUS_EXTENDED_END
'Error 13910 'L’index des paramètres de sécurité du paquet ne correspond pas à une association de sécurité IPsec valide.
'Error 13911 'Un paquet a été reçu sur une association de sécurité IPsec dont la durée de vie a expiré.
'Error 13912 'Un paquet a été reçu sur une association de sécurité IPsec qui ne correspond pas aux caractéristiques du paquet.
'Error 13913 'Échec du contrôle de relecture du numéro de séquence du paquet.
'Error 13914 'L’en-tête et/ou le code de fin IPsec du paquet n’est pas valide.
'Error 13915 'Échec de la vérification d’intégrité IPsec.
'Error 13916 'IPsec a supprimé un paquet de texte en clair.
'Error 13917 'IPsec a rejeté un paquet ESP entrant en mode pare-feu authentifié. Ce rejet est bénin.
'Error 13918 'IPsec a rejeté un paquet en raison de l’accélération DoS.
'Error 13925 'La protection DoS IPsec correspond à une règle de blocage explicite.
'Error 13926 'La protection DoS IPsec a reçu un paquet de multidiffusion spécifique à IPsec, ce qui n’est pas autorisé.
'Error 13927 'La protection DoS IPsec a reçu un paquet de format incorrect.
'Error 13928 'La protection DoS IPsec n’a pas pu rechercher l’état.
'Error 13929 'La protection DoS IPsec n’a pas pu créer d’état car le nombre maximal d’entrées autorisé par la stratégie a été atteint.
'Error 13930 'La protection DoS IPsec a reçu un paquet de négociation IPsec pour un module de génération de clés, ce qui n’est pas autorisé par la stratégie.
'Error 13931 'La protection DoS IPsec n’a pas été activée.
'Error 13932 'La protection DoS IPsec n’a pas pu créer de file d’attente par limite de débit IP interne car le nombre maximal de files d’attente autorisé par la stratégie a été atteint.
'Error 14000 'La section requise n’était pas présente dans le contexte d’activation.
'Error 14001 'L’application n’a pas pu démarrer car sa configuration côte-à-côte est incorrecte. Pour plus d’informations, consultez le journal des événements des applications ou utilisez l’outil de ligne de commande sxstrace.exe.
'Error 14002 'Le format de données de la liaison de l’application n’est pas valide.
'Error 14003 'L’assembly référencé n’est pas installé sur votre système.
'Error 14004 'Le fichier manifeste ne commence pas avec la balise et les informations de format nécessaires.
'Error 14005 'Le fichier manifeste contient une ou plusieurs erreurs de syntaxe.
'Error 14006 'L’application a tenté d’activer un contexte d’activation désactivé.
'Error 14007 'La clé de recherche requise n’a été trouvée dans aucun contexte d’activation actif.
'Error 14008 'La version du composant requise par l’application est en conflit avec une autre version déjà active du composant.
'Error 14009 'Le type a requis une section de contexte d’activation qui ne correspond pas à l’API de la requête.
'Error 14010 'La pénurie de ressources système a nécessité que l’activation isolée soit désactivée pour le thread d’exécution actuel.
'Error 14011 'Une tentative de définition du contexte d’activation du processus par défaut a échoué car le contexte d’activation du processus par défaut était déjà configuré.
'Error 14012 'L’identificateur de groupe de codage spécifié n’est pas reconnu.
'Error 14013 'Le codage requis n’est pas reconnu.
'Error 14014 'Le fichier manifeste contient une référence à un URI non valide.
'Error 14015 'Le fichier manifeste d’application contient une référence à un assemblage dépendant qui n’est pas installé
'Error 14016 'Le fichier manifeste pour un assemblage utilisé par l’application contient une référence à un assemblage dépendant qui n’est pas installé
'Error 14017 'Le fichier manifeste contient un attribut pour l’identité d’assemblage qui n’est pas valide.
'Error 14018 'La spécification demandée d’espace de nom par défaut dans l’élément d’assemblage manque au manifeste.
'Error 14019 'Le manifeste possède un espace de nom par défaut spécifié dans l’élément d’assemblage mais sa valeur n’est pas "urn:schemas-microsoft-com:asm.v1".
'Error 14020 'Le manifeste privé détecté a croisé un chemin avec un point d’analyse non pris en charge.
'Error 14021 'Deux composants ou plus référencés directement ou indirectement par le manifeste de l’application possèdent des fichiers portant le même nom.
'Error 14022 'Deux composants ou plus référencés directement ou indirectement par le manifeste de l’application possèdent des classes de fenêtrage portant le même nom.
'Error 14023 'Deux composants ou plus référencés directement ou indirectement par le manifeste de l’application possèdent les mêmes CLSID du serveur COM.
'Error 14024 'Deux composants ou plus référencés directement ou indirectement par le manifeste de l’application possèdent des proxy pour les mêmes IID de l’interface COM.
'Error 14025 'Deux composants ou plus référencés directement ou indirectement par le manifeste de l’application possèdent les mêmes TLBID de bibliothèque de type COM.
'Error 14026 'Deux ou plusieurs composants référencés directement ou indirectement par le manifeste de l’application ont le même identificateur de programme COM.
'Error 14027 'Deux ou plusieurs composants référencés directement ou indirectement par le manifeste de l’application sont des versions différentes du même composant. Ceci n’est pas autorisé.
'Error 14028 'Un fichier du composant ne correspond pas aux informations de vérification présentes dans le manifeste du composant.
'Error 14029 'Le fichier manifeste de stratégie contient une ou plusieurs erreurs de syntaxe.
'Error 14030 'Erreur d’analyse du fichier manifeste  'un opérateur de chaîne était attendu, mais aucun guillemet d’ouverture n’a été trouvé.
'Error 14031 'Erreur d’analyse du fichier manifeste  'une syntaxe incorrecte a été utilisée en commentaire.
'Error 14032 'Erreur d’analyse du fichier manifeste  'nom commençant par un caractère non valide.
'Error 14033 'Erreur d’analyse du fichier manifeste  'un nom contenait un caractère non valide.
'Error 14034 'Erreur d’analyse du fichier manifeste  'un opérateur de chaîne contenait un caractère non valide.
'Error 14035 'Erreur d’analyse du fichier manifeste  'syntaxe non valide pour une déclaration XML.
'Error 14036 'Erreur d’analyse du fichier manifeste  'un caractère non valide a été trouvé dans le contenu du texte.
'Error 14037 'Erreur d’analyse du fichier manifeste  'un espace requis était manquant.
'Error 14038 'Erreur d’analyse du fichier manifeste  'le caractère '>' était attendu.
'Error 14039 'Erreur d’analyse du fichier manifeste  'un point virgule était attendu.
'Error 14040 'Erreur d’analyse du fichier manifeste  'parenthèses non équilibrées.
'Error 14041 'Erreur d’analyse du fichier manifeste  'erreur interne.
'Error 14042 'Erreur d’analyse du fichier manifeste  'l’espace n’est pas autorisé à cet emplacement.
'Error 14043 'Erreur d’analyse du fichier manifeste  'la fin du fichier a atteint un état non valide pour le codage en cours.
'Error 14044 'Erreur d’analyse du fichier manifeste  'parenthèses manquantes.
'Error 14045 'Erreur d’analyse du fichier manifeste  'une apostrophe ou un guillemet de fermeture manque (\' ou \").
'Error 14046 'Erreur d’analyse du fichier manifeste  'plusieurs signes deux-points ne sont pas autorisés dans un nom.
'Error 14047 'Erreur d’analyse du fichier manifeste  'caractère non valide pour un nombre décimal.
'Error 14048 'Erreur d’analyse du fichier manifeste  'caractère non valide pour un nombre hexadécimal.
'Error 14049 'Erreur d’analyse du fichier manifeste  'valeur du caractère Unicode non valide pour cette plate-forme.
'Error 14050 'Erreur d’analyse du fichier manifeste  'espace attendu ou '?'.
'Error 14051 'Erreur d’analyse du fichier manifeste  'la balise de fin n’était pas attendue à cet emplacement.
'Error 14052 'Erreur d’analyse du fichier manifeste  'les balises suivantes n’étaient pas fermées  '%1.
'Error 14053 'Erreur d’analyse du fichier manifeste  'attribut dupliqué.
'Error 14054 'Erreur d’analyse du fichier manifeste  'seul un élément de premier niveau est autorisé dans un document XML.
'Error 14055 'Erreur d’analyse du fichier manifeste  'premier niveau du document non valide.
'Error 14056 'Erreur d’analyse du fichier manifeste  'déclaration XML non valide.
'Error 14057 'Erreur d’analyse du fichier manifeste  'le document XML doit avoir un élément de premier niveau.
'Error 14058 'Erreur d’analyse du fichier manifeste  'fin de fichier inattendue.
'Error 14059 'Erreur d’analyse du fichier manifeste  'les entités de paramétrage ne peuvent pas être utilisées dans des déclarations balises dans un sous-ensemble interne.
'Error 14060 'Erreur d’analyse du fichier manifeste  'l’élément n’était pas fermé.
'Error 14061 'Erreur d’analyse du fichier manifeste  'le caractère '>' manquait à l’élément de fin.
'Error 14062 'Erreur d’analyse du fichier manifeste  'un opérateur de chaîne n’a pas été fermé.
'Error 14063 'Erreur d’analyse du fichier manifeste  'un commentaire n’a pas été fermé.
'Error 14064 'Erreur d’analyse du fichier manifeste  'une déclaration n’a pas été fermée.
'Error 14065 'Erreur d’analyse du fichier manifeste  'une section CDATA n’a pas été fermée.
'Error 14066 'Erreur d’analyse du fichier manifeste  'le préfixe de l’espace de noms n’est pas autorisé à démarrer avec la chaîne réservée "xml".
'Error 14067 'Erreur d’analyse du fichier manifeste  'le système ne prend pas en charge le codage spécifié.
'Error 14068 'Erreur d’analyse du fichier manifeste  'passer du codage actuel au codage spécifié n’est pas pris en charge.
'Error 14069 'Erreur d’analyse du fichier manifeste  'le nom 'xml’ est réservé et ne doit être en minuscule.
'Error 14070 'Erreur d’analyse du fichier manifeste  'l’attribut autonome doit avoir la valeur 'oui' ou 'non’.
'Error 14071 'Erreur d’analyse du fichier manifeste  'l’attribut autonome ne peut pas être utilisé dans des entités externes.
'Error 14072 'Erreur d’analyse du fichier manifeste  'numéro de version incorrecte.
'Error 14073 'Erreur d’analyse du fichier manifeste  'signe égal manquant entre l’attribut et la valeur de l’attribut.
'Error 14074 'Erreur de protection de l’assemblage  'impossible de récupérer l’assemblage spécifié.
'Error 14075 'Erreur de protection de l’assemblage  'la clé publique d’un assemblage était trop courte pour être autorisée.
'Error 14076 'Erreur de protection de l’assemblage  'le catalogue d’un assemblage n’est pas valide ou ne correspond pas au manifeste de l’assemblage.
'Error 14077 'Un HRESULT n’a pas pu être traduit en un code d’erreur Win32 correspondant.
'Error 14078 'Erreur de protection de l’assemblage  'le catalogue d’un assemblage est absent.
'Error 14079 'Un ou plusieurs attributs manquent à l’identité d’assemblage fournie et doivent être présent dans ce contexte.
'Error 14080 'L’identité d’assemblage fournie a un ou plusieurs noms d’attributs qui contiennent des caractères non autorisés dans des noms XML.
'Error 14081 'L’assembly référencé n’a pas pu être trouvé.
'Error 14082 'La pile d’activation du contexte d’activation pour le thread d’exécution actuel est endommagée.
'Error 14083 'Les métadonnées d’isolation de l’application pour ce processus ou thread sont endommagées.
'Error 14084 'Le contexte d’activation en cours de désactivation n’est pas le contexte activé le plus récemment.
'Error 14085 'Le contexte d’activation en cours de désactivation n’est pas actif pour le thread d’exécution actuelle.
'Error 14086 'Le contexte d’activation en cours de désactivation a déjà été désactivé.
'Error 14087 'Un composant utilisé pour l’utilitaire d’isolation a demandé de terminer le processus.
'Error 14088 'Un composant en mode noyau publie une référence sur un contexte d’activation.
'Error 14089 'Le contexte d’activation de l’assemblage système par défaut n’a pas pu être généré.
'Error 14090 'La valeur d’un attribut d’une identité n’est pas comprise dans la plage autorisée.
'Error 14091 'Le nom d’un attribut d’une identité n’est pas compris dans la plage autorisée.
'Error 14092 'Une identité contient deux définitions pour le même attribut.
'Error 14093 'Le format de la chaîne d’identité est incorrect. Cela peut être dû à une virgule de fin, plus de deux attributs non nommés, un nom d’attribut manquant ou une valeur d’attribut manquante.
'Error 14094 'Une chaîne contenant du contenu substituable localisé était malformée. Soit un signe dollar ($) était suivi d’un signe autre qu’une parenthèse gauche ou d’un autre signe dollar, soit une parenthèse droite de substitution était introuvable.
'Error 14095 'Le jeton de clé publique ne correspond pas à la clé publique spécifiée.
'Error 14096 'Une chaîne de substitution n’avait pas de mappage.
'Error 14097 'Le composant doit être verrouillé avant d’effectuer la demande.
'Error 14098 'Le magasin de composants a été endommagé.
'Error 14099 'Un programme d’installation avancé a échoué pendant l’installation ou le service.
'Error 14100 'Le codage de caractères utilisé dans la déclaration XML ne correspondait pas au codage utilisé dans le document.
'Error 14101 'Les identités des manifestes sont identiques mais leur contenu est différent.
'Error 14102 'Les identités des composants sont différentes.
'Error 14103 'L’assembly n’est pas un déploiement.
'Error 14104 'Le fichier ne fait pas partie de l’assembly.
'Error 14105 'La taille du manifeste dépasse la taille maximale autorisée.
'Error 14106 'Le paramètre n’est pas inscrit.
'Error 14107 'Un ou plusieurs membres requis de la transaction sont absents.
'Error 14108 'Le programme d’installation primitif de SMI a échoué lors de l’installation ou de la maintenance.
'Error 14109 'Un exécutable de commande générique a renvoyé un résultat qui indique un échec.
'Error 14110 'Des informations de vérification de fichier sont manquantes dans le manifeste d’un composant.
'Error 15000 'Le chemin d’accès du canal spécifié n’est pas valide.
'Error 15001 'La requête spécifiée n’est pas valide.
'Error 15002 'Métadonnées du serveur de Publication introuvables dans la ressource.
'Error 15003 'Modèle de définition d’événement introuvable dans la ressource (erreur = %1).
'Error 15004 'Le nom de l’éditeur spécifié n’est pas valide.
'Error 15005 'Les données d’événement déclenchées par le serveur de Publication ne sont pas compatibles avec la définition du modèle d’événement dans le manifeste du serveur de Publication.
'Error 15007 'Canal spécifié introuvable. Vérifiez sa configuration.
'Error 15008 'Le texte XML spécifié était malformé. Pour plus d’informations, voir l’erreur étendue.
'Error 15009 'L’appelant essaie de s’abonner à un canal direct non autorisé. Les événements d’un canal direct vont directement dans un fichier journal et il n’est plus possible de s’y abonner.
'Error 15010 'Erreur de configuration.
'Error 15011 'Le résultat de la requête est obsolète/non valide. Cela peut être dû au journal qui a été effacé ou remplacé après la création du résultat de la requête. Les utilisateurs peuvent gérer ce code en libérant l’objet résultat de la requête et en réémettant la requ
'Error 15012 'La position du résultat de la requête n’est pas valide.
'Error 15013 'Le MSXML inscrit ne prend pas en charge la validation.
'Error 15014 'Une expression peut être suivie uniquement par une modification de l’opération d’étendue si elle prend elle-même la valeur d’un nœud et si elle ne fait pas déjà partie d’une autre modification de l’opération d’étendue.
'Error 15015 'Impossible d’effectuer une opération en une étape à partir d’un terme qui ne représente pas un jeu d’éléments.
'Error 15016 'Les arguments situés à gauche des opérateurs binaires doivent être des attributs, des nœuds ou des variables et les arguments situés à droite doivent être des constantes.
'Error 15017 'Une opération en une étape doit inclure un Test de nœud ou, dans le cas d’un prédicat, une expression algébrique par rapport à laquelle le Test de chaque nœud du jeu de nœuds identifié par le jeu de nœuds précédent peut être évalué.
'Error 15018 'Ce type de données n’est pas pris en charge actuellement.
'Error 15019 'Erreur de syntaxe survenue à la position %1!d!
'Error 15020 'Cet opérateur n’est pas pris en charge par l’implémentation du filtre.
'Error 15021 'Jeton trouvé inattendu.
'Error 15022 'Impossible d’effectuer l’opération demandée sur un canal direct activé. Le canal doit d’abord être désactivé pour que l’opération demandée puisse être effectuée.
'Error 15023 'La propriété de canal %1 contient une valeur non valide. La valeur a un type non valide, est en dehors de la plage autorisée, ne peut pas être mise à jour ou n’est pas prise en charge par ce type de canal.
'Error 15024 'La propriété de serveur de Publication %1 contient une valeur non valide. La valeur a un type non valide, est en dehors de la plage autorisée, ne peut être mise à jour ou n’est pas prise en charge par ce type de serveur de Publication.
'Error 15025 'Échec d’activation du canal.
'Error 15026 'L’expression xpath a dépassé le niveau de complexité pris en charge. Simplifiez-la ou divisez-la en au moins deux expressions plus simples.
'Error 15027 'La ressource de message est présente mais le message ne se trouve pas dans la table des chaînes ou des messages.
'Error 15028 'L’identificateur du message désiré est introuvable.
'Error 15029 'Impossible de trouver la chaîne de substitution pour l’index inséré %1.
'Error 15030 'Impossible de trouver la chaîne de description pour la référence de paramètre %1.
'Error 15031 'Le nombre maximal de remplacements a été atteint.
'Error 15032 'Impossible de trouver la définition de l’événement dont l’identificateur est %1.
'Error 15033 'La ressource spécifique de l’option régionale du message désiré n’est pas présente.
'Error 15034 'La ressource est trop ancienne pour être compatible.
'Error 15035 'La ressource est trop récente pour être compatible.
'Error 15036 'Impossible d’ouvrir le canal à l’index %1!d! de la requête.
'Error 15037 'Le serveur de Publication a été désactivé et ses ressources ne sont pas disponibles. Cela se produit généralement lorsque le serveur de Publication est en cours de désinstallation ou de mise à niveau.
'Error 15038 'Tentative de création d’un type numérique en dehors de sa plage autorisée.
'Error 15080 'L’abonnement n’a pas pu être activé.
'Error 15081 'L’état du journal de l’abonnement est désactivé et ne peut pas être utilisé pour transmettre les événements. Le journal doit d’abord être activé avant de pouvoir activer l’abonnement.
'Error 15082 'Lors du transfert d’événements de l’ordinateur local à lui-même, la requête de l’abonnement ne peut pas contenir le journal cible de l’abonnement.
'Error 15083 'Le magasin d’informations d’identification servant à enregistrer les informations d’identification est plein.
'Error 15084 'Les informations d’identification utilisées par cet abonnement sont introuvables dans le magasin d’informations d’identification.
'Error 15085 'Impossible de trouver un canal actif pour la requête.
'Error 15100 'Le chargeur de ressources n’a pas pu trouver le fichier MUI.
'Error 15101 'Le chargeur de ressources n’a pas pu charger le fichier MUI car le fichier a échoué au Test de validation.
'Error 15102 'Le manifeste RC est endommagé en raison de données parasites, d’une version non prise en charge ou d’un élément requis manquant.
'Error 15103 'Le manifeste RC contient un nom de culture non valide.
'Error 15104 'Le manifeste RC contient un nom de base par défaut non valide.
'Error 15105 'Aucune entrée MUI n’est chargée dans le cache du chargeur de ressources.
'Error 15106 'L’utilisateur a arrêté l’énumération des ressources.
'Error 15107 'Échec de l’installation de la langue d’interface utilisateur.
'Error 15108 'Échec de l’installation des paramètres régionaux.
'Error 15110 'Une ressource n’a pas de valeur par défaut ou neutre.
'Error 15111 'Fichier de configuration PRI non valide.
'Error 15112 'Type de fichier non valide.
'Error 15113 'Qualificateur inconnu.
'Error 15114 'Valeur de qualificateur non valide.
'Error 15115 'Aucun candidat trouvé.
'Error 15116 'Le ResourceMap ou le NamedResource a un élément qui n’a pas de ressource par défaut ou neutre.
'Error 15117 'Type de ResourceCandidate non valide.
'Error 15118 'Mappage de ressources en double.
'Error 15119 'Entrée en double.
'Error 15120 'Identificateur de ressource non valide.
'Error 15121 'Chemin d’accès au fichier trop long.
'Error 15122 'Type de répertoire non pris en charge.
'Error 15126 'Fichier PRI non valide.
'Error 15127 'NamedResource introuvable.
'Error 15135 'ResourceMap introuvable.
'Error 15136 'Type de profil MRT non pris en charge.
'Error 15137 'Opérateur qualificatif non valide.
'Error 15138 'Impossible de déterminer la valeur du qualificateur ou la valeur du qualificateur n’a pas été définie.
'Error 15139 'La fusion automatique est activée dans le fichier PRI.
'Error 15140 'Trop de ressources définies pour le package.
'Error 15141 'Un fichier de ressources ne peut pas être utilisé pour une opération de fusion.
'Error 15142 'Impossible d’utiliser Load/UnloadPriFiles avec des packages de ressources.
'Error 15143 'Impossible de créer des contextes de ressources sur des threads qui n’ont pas CoreWindow.
'Error 15144 'Le gestionnaire de ressources singleton avec un profil distinct est déjà créé.
'Error 15145 'Le composant système ne peut pas fonctionner en raison de l’exécution de l’API.
'Error 15146 'La ressource est une référence directe à une ressource candidate qui n’est pas une ressource candidate par défaut.
'Error 15147 'Le mappage des ressources a été régénéré, et la chaîne de requête n’est plus valide.
'Error 15148 'Les versions des fichiers PRI à fusionner ne sont pas compatibles.
'Error 15149 'Les fichiers PRI principaux à fusionner ne contiennent pas de schéma.
'Error 15150 'Impossible de charger l’un des fichiers PRI à fusionner.
'Error 15151 'Impossible d’ajouter l’un des fichiers PRI au fichier fusionné.
'Error 15152 'Impossible de créer le fichier PRI fusionné.
'Error 15153 'Les packages pour la fusion des fichiers PRI doivent tous provenir de la même famille de packages.
'Error 15154 'Les packages pour la fusion des fichiers PRI ne doivent pas inclure plusieurs packages principaux.
'Error 15155 'Les packages pour la fusion des fichiers PRI ne doivent pas inclure de package de lots.
'Error 15156 'Les packages pour la fusion des fichiers PRI doivent inclure au moins un package principal.
'Error 15157 'Les packages pour la fusion des fichiers PRI doivent inclure au moins un package de ressources.
'Error 15158 'Nom incorrect fourni pour un fichier PRI fusionné canonique.
'Error 15200 'Le moniteur a renvoyé une chaîne de fonctionnalités DDC/CI qui n’était conforme avec la spécification ACCESS.bus 3.0, DDC/CI 1.1 ou MCCS 2 Révision 1.
'Error 15201 'Le code VCP (0xDF) de la version VCP du moniteur a retourné une valeur de version non valide.
'Error 15202 'Le moniteur n’est pas compatible avec la spécification MCCS qu’il prétend prendre en charge.
'Error 15203 'La version MCCS de la fonctionnalité mccs_ver d’un moniteur ne correspond pas à celle que le moniteur signale lorsque le code VCP (0xDF) de la version VCP est utilisé.
'Error 15204 'L’API de configuration de moniteur fonctionne uniquement avec des moniteurs prenant en charge la spécification MCCS 1.0, la spécification MCCS 2.0 ou la spécification MCCS 2.0 Révision 1.
'Error 15205 'Erreur interne d’API de configuration de moniteur.
'Error 15206 'Le moniteur a retourné un type de technologie de moniteur non valide. CRT, Plasma et LCD (TFT) sont des exemples de types de technologies de moniteur. Cette erreur implique que le moniteur ne respecte pas la spécification MCCS 2.0 ou MCCS 2.0 révision 1.
'Error 15207 'L’appelant de SetMonitorColorTemperature() a spécifié une température de couleur que le moniteur actuel ne prenait pas en charge. Cette erreur implique que le moniteur a violé la spécification MCCS 2.0 ou MCCS 2.0 Révision 1.
'Error 15250 'Impossible d’identifier le périphérique système demandé car plusieurs périphériques non différentiables correspondent aux critères d’identification.
'Error 15299 'Le périphérique système demandé est introuvable.
'Error 15300 'La génération de hachage pour la version et le type de hachage spécifiés n’est pas activée sur le serveur.
'Error 15301 'Le hachage demandé depuis le serveur n’est pas disponible ou n’est plus valide.
'Error 15321 'L’instance secondaire du contrôleur d’interruptions qui gère l’interruption spécifiée n’est pas inscrite.
'Error 15322 'Les informations fournies par le pilote du client GPIO ne sont pas valides.
'Error 15323 'La version spécifiée par le pilote du client GPIO n’est pas prise en charge.
'Error 15324 'Le paquet d’inscription fourni par le pilote du client GPIO n’est pas valide.
'Error 15325 'L’opération demandée n’est pas prise en charge pour le handle spécifié.
'Error 15326 'Le mode de connexion demandé est en conflit avec un mode existant sur une ou plusieurs des broches spécifiées.
'Error 15327 'L’interruption à afficher n’est pas masquée.
'Error 15400 'Le commutateur de niveau d’exécution demandé ne peut pas aboutir.
'Error 15401 'Le paramètre de niveau d’exécution du service n’est pas valide. Le niveau d’exécution d’un service ne doit pas être supérieur à celui de ses services dépendants.
'Error 15402 'Le commutateur de niveau d’exécution demandé ne peut pas aboutir, car un ou plusieurs services ne s’arrêteront pas ou ne redémarreront pas dans le délai d’expiration spécifié.
'Error 15403 'Un agent de commutation de niveau d’exécution n’a pas répondu dans le délai d’expiration spécifié.
'Error 15404 'Un commutateur de niveau d’exécution est en cours.
'Error 15405 'Un ou plusieurs services n’ont pas pu démarrer lors de la phase de démarrage de service d’un commutateur de niveau d’exécution.
'Error 15501 'Impossible de traiter la demande d’arrêt de tâche immédiatement, car  l’arrêt de la tâche nécessite davantage de temps.
'Error 15600 'Impossible d’ouvrir le package.
'Error 15601 'Le package est introuvable.
'Error 15602 'Les données du package ne sont pas valide.
'Error 15603 'Échec des mises à jour, de la dépendance ou de la validation des conflits du package.
'Error 15604 'L’espace disque est insuffisant sur votre ordinateur. Libérez de l’espace, puis réessayez.
'Error 15605 'Un problème s’est produit lors du chargement de votre produit.
'Error 15606 'Impossible d’inscrire le package.
'Error 15607 'Impossible d’annuler l’inscription du package.
'Error 15608 'L’utilisateur a annulé la demande d’installation.
'Error 15609 'Échec de l’installation. Contactez votre fournisseur de logiciel.
'Error 15610 'Échec de la suppression. Contactez votre fournisseur de logiciel.
'Error 15611 'Le package spécifié est déjà installé. La réinstallation du package a été bloquée. Pour plus d’informations, consultez le journal des événements AppXDeployment-Server.
'Error 15612 'Impossible de démarrer l’application. Essayez de la réinstaller pour résoudre le problème.
'Error 15613 'Une condition requise pour une installation n’a pas pu être satisfaite.
'Error 15614 'Le répertoire de stockage du package est endommagé.
'Error 15615 'L’installation de cette application requiert une licence de développeur Windows ou un système compatible avec le chargement indépendant.
'Error 15616 'Impossible de démarrer l’application, car elle est en cours de mise à jour.
'Error 15617 'L’opération de déploiement du package est bloquée par une stratégie. Contactez votre administrateur système.
'Error 15618 'Impossible d’installer le package car des ressources qu’il modifie sont actuellement utilisées.
'Error 15619 'Impossible de récupérer le package car des données nécessaires à la récupération ont été endommagées.
'Error 15620 'La signature n’est pas valide. Pour s’inscrire en mode développeur, AppxSignature.p7x et AppxBlockMap.xml doivent être valides ou ne doivent pas être présents.
'Error 15621 'Une erreur s’est produite lors de la suppression des données d’application existantes du package.
'Error 15622 'Impossible d’installer ce package, car une version ultérieure est déjà installée.
'Error 15623 'Une erreur a été détectée dans un système binaire. Actualisez l’ordinateur pour résoudre le problème.
'Error 15624 'Un code binaire NGEN du CLR endommagé a été détecté sur le système.
'Error 15625 'Impossible de reprendre l’opération car les données nécessaires pour la récupération ont été endommagées.
'Error 15626 'Impossible d’installer le package, car le service Pare-feu Windows n’est pas en cours d’exécution. Activez le service Pare-feu Windows et réessayez.
'Error 15627 'Échec de déplacement du package.
'Error 15628 'Échec de l'opération de déploiement, car le volume n'est pas vide.
'Error 15629 'Échec de l'opération de déploiement, car le volume est hors ligne.
'Error 15630 'Échec de l'opération de déploiement, car le volume spécifié est endommagé.
'Error 15631 'Échec de l'opération de déploiement, car l'application spécifiée doit d'abord être inscrite.
'Error 15632 'L 'opération de déploiement a échoué, car le package cible l'architecture de processeur incorrecte.
'Error 15633 'Vous avez atteint le nombre maximal de packages de chargement de version Test de développeur autorisés sur ce périphérique. Veuillez désinstaller un package de chargement de version Test, puis réessayez.
'Error 15634 'Un package d’application principal est nécessaire pour installer ce package facultatif. Installez le package principal et réessayez.
'Error 15635 'Ce type package d’application n’est pas pris en charge sur ce système de fichiers
'Error 15636 'L’opération du déplacement du package est bloquée jusqu’à ce que la diffusion de l’application soit terminée
'Error 15637 'Un package d’application principal ou un autre package facultatif présente le même ID d’application que ce package facultatif. Modifiez l’ID d’application du package facultatif pour éviter les conflits.
'Error 15638 'Cette session intermédiaire a été suspendue, de sorte qu'une autre opération intermédiaire puisse être traitée en priorité.
'Error 15639 'Il n’est pas possible de mettre à jour un jeu associé, car le jeu mis à jour n’est pas valide. Tous les packages du jeu associé doivent être mis à jour simultanément.
'Error 15640 'Un package facultatif avec un point d'entrée FullTrust nécessite que le package principal dispose de la fonctionnalité runFullTrust.
'Error 15641 'Une erreur s’est produite, car un utilisateur a fermé une session.
'Error 15642 'Un approvisionnement de package supplémentaire requiert que le package de dépendances principal soit également approvisionné.
'Error 15643 'Les packages ont échoué à la vérification de réputation SmartScreen.
'Error 15644 'L 'opération de vérification de réputation SmartScreen a échoué.
'Error 15700 'Le processus n’a aucune identité de package.
'Error 15701 'Les informations d’exécution du package sont endommagées.
'Error 15702 'L’identité du package est endommagée.
'Error 15703 'Le processus n’a aucune identité d’application.
'Error 15704 'Impossible de lire une ou plusieurs valeurs de stratégie de groupe du runtime AppModel. Contactez votre administrateur système en lui indiquant le contenu de votre journal des événements du runtime AppModel.
'Error 15705 'Une ou plusieurs valeurs de stratégie de groupe du runtime AppModel ne sont pas valides. Contactez votre administrateur système en lui indiquant le contenu de votre journal des événements du runtime AppModel.
'Error 15706 'Le package n'est pas actuellement disponible.
'Error 15800 'Échec du chargement du magasin d’état.
'Error 15801 'Échec de la récupération de la version d’état de l’application.
'Error 15802 'Échec de la définition de la version d’état de l’application.
'Error 15803 'Échec de la redéfinition de l’état structuré de l’application.
'Error 15804 'Le gestionnaire d’états n’a pas pu ouvrir le conteneur.
'Error 15805 'Le gestionnaire d’états n’a pas pu créer le conteneur.
'Error 15806 'Le gestionnaire d’états n’a pas pu supprimer le conteneur.
'Error 15807 'Le gestionnaire d’états n’a pas pu lire le paramètre.
'Error 15808 'Le gestionnaire d’états n’a pas pu écrire le paramètre.
'Error 15809 'Le gestionnaire d’états n’a pas pu supprimer le paramètre.
'Error 15810 'Le gestionnaire d’états n’a pas pu interroger le paramètre.
'Error 15811 'Le gestionnaire d’états n’a pas pu lire le paramètre composite.
'Error 15812 'Le gestionnaire d’états n’a pas pu écrire le paramètre composite.
'Error 15813 'Le gestionnaire d’états n’a pas pu énumérer les conteneurs.
'Error 15814 'Le gestionnaire d’états n’a pas pu énumérer les paramètres.
'Error 15815 'La taille de valeur de paramètre composite du gestionnaire d’états a dépassé la limite.
'Error 15816 'La taille de valeur de paramètre du gestionnaire d’états a dépassé la limite.
'Error 15817 'La longueur de nom de paramètre du gestionnaire d’états a dépassé la limite.
'Error 15818 'La longueur de nom de conteneur du gestionnaire d’états a dépassé la limite.
'Error 15841 'Impossible d’utiliser cette API dans le contexte du type d’application de l’appelant.
'Error 15861 'Cet ordinateur ne dispose pas d’une licence valide pour l’application ou le produit.
'Error 15862 'L’utilisateur authentifié ne dispose pas d’une licence valide pour l’application ou le produit.
'Error 15863 'La transaction commerciale associée à cette licence est toujours en cours de vérification.
'Error 15864 'La licence a été révoquée pour cet utilisateur.
