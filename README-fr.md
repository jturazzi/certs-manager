# cert_manager.sh

## Vue d'ensemble

`cert_manager.sh` est un script Bash conçu pour simplifier le processus de création, de gestion et de signature des certificats SSL/TLS. Ce script offre une méthode facile pour générer un certificat d'Autorité de Certification (CA), créer des Demandes de Signature de Certificat (CSR), et signer des certificats en utilisant votre CA.

## Fonctionnalités

- **Créer un certificat CA :** Générer un certificat d'Autorité de Certification (CA) avec un nom personnalisé. Le certificat CA sera valide pour 10 ans.
- **Générer et signer des certificats :** Générer automatiquement une Demande de Signature de Certificat (CSR) et la signer en utilisant un certificat CA existant. Le certificat signé sera valide pour 1 an.

## Prérequis

Pour utiliser ce script, vous devez disposer de :

- Un système d'exploitation de type Unix (Linux, macOS, etc.).
- OpenSSL installé sur votre système (la commande `openssl` doit être disponible).

## Utilisation

1. **Téléchargez le script :**

   ```bash
   wget https://path_to_your_script/cert_manager.sh
   ```

   Ou clonez le dépôt :

   ```bash
   git clone https://github.com/jturazzi/certs-manager.git
   ```

2. **Rendez le script exécutable :**

   ```bash
   chmod +x cert_manager.sh
   ```

3. **Exécutez le script :**

   ```bash
   ./cert_manager.sh
   ```

   Vous serez invité à choisir l'action que vous souhaitez effectuer via un menu.

### Options du menu

1. **Créer un certificat CA (10 ans) :**
   - Entrez un nom de dossier pour stocker le certificat CA et un nom personnalisé pour le CA.
   - Le script générera un nouveau certificat CA et l'enregistrera dans le dossier spécifié.

2. **Générer et signer un certificat (1 an) :**
   - Entrez le nom du dossier CA, le nom du dossier pour la CSR, un nom personnalisé pour la CSR, et éventuellement une liste de noms de domaine et d'adresses IP.
   - Le script générera une CSR, la signera en utilisant le CA spécifié, et créera un nouveau certificat dans le dossier indiqué.

3. **Quitter :**
   - Quitte le script.

### Exemple

- **Création d'un certificat CA :**

   Si vous choisissez de créer un certificat CA, il vous sera demandé de fournir :
   - Le nom du dossier (par exemple, `myCA`)
   - Un nom personnalisé pour le CA (par exemple, `MyCompanyCA`)

   Le script créera un certificat CA dans le dossier `myCA`.

- **Génération et signature d'un certificat :**

   Si vous choisissez de générer et signer un certificat, vous devrez fournir :
   - Le nom du dossier CA (par exemple, `myCA`)
   - Le nom du dossier pour la CSR (par exemple, `myCert`)
   - Un nom personnalisé pour la CSR (par exemple, `MonSiteWeb`)
   - (Facultatif) Les noms de domaine (par exemple, `example.com,www.example.com`)
   - (Facultatif) Les adresses IP (par exemple, `192.168.1.1,192.168.1.2`)

   Le script générera une CSR et la signera, ce qui aboutira à la création d'un nouveau certificat dans le dossier `myCert`.

## Remarques

- Le script suppose que la structure des dossiers sera organisée, avec des dossiers distincts pour chaque CA et chaque CSR.
- Assurez-vous que les noms fournis ne sont pas en conflit avec des dossiers ou fichiers existants pour éviter des erreurs.

## Licence

Ce projet est sous licence MIT - consultez le fichier [LICENSE](LICENSE) pour plus de détails.