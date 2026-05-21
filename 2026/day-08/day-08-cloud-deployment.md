Date: 24 May 2026

🐧 Day 08 – Cloud Server Setup: Docker, Nginx & Web Deployment

Part 1: Launch Cloud Instance & SSH Access

    Step 1: Create a Cloud Instance
        
        1. Logged into the AWS Console and navigated to the EC2 Dashboard.
        2. Clicked on Launch Instance and configured the following:
            - Name: "Rajat-Demo-Instance"
            - OS Images (AMI): "Ubuntu Server 26.04 LTS (HVM), SSD Volume Type" (Free tier eligible)
            - Instance Type: "t3.micro"
            - Key Pair: Created a new key pair named "KEY_FILE_NAME.pem" and downloaded it to the local machine.
            - Network Settings:
                - Allowed SSH traffic from Anywhere ("0.0.0.0/0").
                - Allowed HTTP traffic from Anywhere ("0.0.0.0/0") for web access.
        3. Clicked Launch Instance to provision the cloud server.

<img width="1914" height="201" alt="Screenshot 2026-05-21 at 6 02 00 PM" src="https://github.com/user-attachments/assets/1c8603a0-e970-4172-814a-99b81ce52dc8" />

<img width="1625" height="261" alt="Screenshot 2026-05-21 at 6 07 09 PM" src="https://github.com/user-attachments/assets/7502291b-296b-4aee-8913-672795832ff8" />

    Step 2: Connect via SSH

        Open a local terminal and navigate to the directory where the "KEY_FILE_NAME.pem" file was saved, then run the following commands:

            1. Set permissions for the private key (owner read-only):
                
                chmod 400 KEY_FILE_NAME.pem
            
            2. Connect to the EC2 instance via SSH:
            
                ssh -i "KEY_FILE_NAME.pem" ubuntu@YOUR_INSTANCE_PUBLIC_IP_OR_DNS

<img width="849" height="580" alt="Screenshot 2026-05-21 at 6 03 03 PM" src="https://github.com/user-attachments/assets/03840bc1-61be-4d2a-ae40-652cd07abed5" />

----------------------------------------------------------------------------------------------------------------------------------------------------

Part 2: Install Docker & Nginx

    Step 1: Update System
    
        Always update the package repository index to ensure the latest versions are fetched.

            sudo apt update && sudo apt upgrade -y

    Step 2: Install Docker & Nginx
        
        1. Install Docker:

            sudo apt install docker.io -y
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo usermod -aG docker ubuntu
   
   ***Note: Close and reopen your terminal session, or run "newgrp docker" to apply user group additions.***

        2. Install Nginx:
            
            sudo apt install nginx -y

<img width="1908" height="864" alt="Screenshot 2026-05-21 at 6 05 53 PM" src="https://github.com/user-attachments/assets/eb74d0cb-fe07-4e6b-99c4-4115096aabd4" />

        3. Verify Nginx is running
        
            sudo systemctl status nginx

<img width="1180" height="460" alt="Screenshot 2026-05-21 at 6 12 17 PM" src="https://github.com/user-attachments/assets/90c2abb1-026d-41b1-a499-de89c2c07338" />

        4. Verify Docker is running:
        
            docker --version

<img width="336" height="24" alt="Screenshot 2026-05-21 at 6 44 19 PM" src="https://github.com/user-attachments/assets/5a6485b0-fbbc-44e9-8c51-b0dbbe5ccfaa" />

----------------------------------------------------------------------------------------------------------------------------------------------------

Part 3: Security Group Configuration

    Test Web Access. Open your web browser and visit the public IP of your instance:
    
    If security groups are configured correctly (Port 80 HTTP traffic is allowed), you will see the Nginx welcome page.

    Alternatively, check server response from your local machine:

        curl -I <YOUR INSTANCE PUBLIC IP>

<img width="1086" height="318" alt="Screenshot 2026-05-21 at 6 08 41 PM" src="https://github.com/user-attachments/assets/6fd7f821-1d05-4c73-a890-fc35a8af1bcb" />

----------------------------------------------------------------------------------------------------------------------------------------------------

Part 4: Extract Nginx Logs

    1: View Nginx Logs
    
        Monitor the incoming requests to Nginx in real-time.

            tail -f /var/log/nginx/access.log

<img width="1893" height="161" alt="Screenshot 2026-05-21 at 6 45 27 PM" src="https://github.com/user-attachments/assets/8679dd46-be10-47bc-9ff4-d48a3067885a" />

    2: Save Logs to File

        Save the last 50 lines of access logs to a file in the user's home directory.
        
            sudo tail -n 50 /var/log/nginx/access.log > ~/nginx-logs.txt

        Verify that the file is created and has contents:
            
            cat ~/nginx-logs.txt

<img width="1893" height="173" alt="Screenshot 2026-05-21 at 6 47 48 PM" src="https://github.com/user-attachments/assets/d5c63c5f-9906-4284-aa40-2faef378fa83" />

    3: Download Log File to Your Local Machine
    
        From a new terminal window on your local machine, run the "scp" command to download the log file:

        Using SSH Private Key

            scp -i KEY_FILE_NAME.pem ubuntu@YOUR_INSTANCE_PUBLIC_IP_OR_DNS:~/nginx-logs.txt .

<img width="1868" height="203" alt="Screenshot 2026-05-21 at 6 51 07 PM" src="https://github.com/user-attachments/assets/df6409e8-325c-47d5-839d-da478375fd56" />

----------------------------------------------------------------------------------------------------------------------------------------------------

Commands Used

| Command | Purpose |
|---------|---------|
| "chmod 400 KEY_FILE_NAME.pem" | Restricts access permissions of private key file |
| "ssh -i <key> ubuntu@<ip>" | Establishes secure connection to cloud server |
| "sudo apt update && sudo apt upgrade -y" | Refreshes and upgrades system packages |
| "sudo apt install docker.io nginx -y" | Installs Docker and Nginx packages |
| "sudo systemctl status nginx" | Checks state of the Nginx server |
| "tail -f /var/log/nginx/access.log" | Streams Nginx access logs |
| "sudo tail -n 50 ... > nginx-logs.txt" | Saves last 50 log lines to text file |
| "scp -i <key> ubuntu@<ip>:~/nginx-logs.txt ." | Securely copies file from server to local machine |

----------------------------------------------------------------------------------------------------------------------------------------------------

Challenges Faced

1. Connection Timeout (Security Group issue)
- Problem: When trying to access the instance's public IP on the browser, the page kept loading and eventually timed out.
- Cause: The security group rules only allowed port 22 (SSH) and did not expose port 80 (HTTP) to public traffic.
- Resolution: Updated the Inbound Security Group rules in the AWS Console to add a rule allowing HTTP traffic on port 80 from "0.0.0.0/0" (anywhere).

2. Permissions issue with Private Key ("KEY_FILE_NAME.pem")
- Problem: SSH connection failed with warning: "UNPROTECTED PRIVATE KEY FILE!".
- Cause: Private key was created with default permissions ("644"), which is too open.
- Resolution: Ran "chmod 400 KEY_FILE_NAME.pem" to restrict access permissions to the owner only.

----------------------------------------------------------------------------------------------------------------------------------------------------

What I Learned
- Cloud Instance Provisioning: How to configure and spin up a Linux instance (Ubuntu 22.04 LTS) in AWS.
- Security & Access Control: The importance of setting correct permissions for SSH private keys and managing firewalls via Cloud Security Groups.
- Service Installation: How to setup utility packages like Docker and web servers like Nginx.
- Remote Log Retrieval: How to view application logs in real-time, dump logs to flat files, and transfer them locally using "scp".
