Date: 24 May 2026

🐧 Day 08 – Cloud Server Setup: Docker, Nginx & Web Deployment

Part 1: Launch Cloud Instance & SSH Access

    Step 1: Create a Cloud Instance
        
        1. Logged into the AWS Console and navigated to the EC2 Dashboard.
        2. Clicked on Launch Instance and configured the following:
            - Name: "Day08-DevOps-Server"
            - OS Images (AMI): "Ubuntu Server 22.04 LTS (HVM), SSD Volume Type" (Free tier eligible)
            - Instance Type: "t2.micro"
            - Key Pair: Created a new key pair named "day-08-key.pem" and downloaded it to the local machine.
            - Network Settings:
                - Allowed SSH traffic from Anywhere ("0.0.0.0/0").
                - Allowed HTTP traffic from Anywhere ("0.0.0.0/0") for web access.
        3. Clicked Launch Instance to provision the cloud server.

    Step 2: Connect via SSH

        Open a local terminal and navigate to the directory where the "day-08-key.pem" file was saved, then run the following commands:

            1. Set permissions for the private key (owner read-only):
                
                chmod 400 day-08-key.pem
            
            2. Connect to the EC2 instance via SSH:
            
                ssh -i "day-08-key.pem" ubuntu@54.210.85.112

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

        3. Verify Nginx is running
        
            sudo systemctl status nginx

        4. Verify Docker is running:
        
            docker --version

----------------------------------------------------------------------------------------------------------------------------------------------------

Part 3: Security Group Configuration

    Test Web Access. Open your web browser and visit the public IP of your instance:
    
    If security groups are configured correctly (Port 80 HTTP traffic is allowed), you will see the Nginx welcome page.

    Alternatively, check server response from your local machine:

        curl -I <YOUR INSTANCE PUBLIC IP>

----------------------------------------------------------------------------------------------------------------------------------------------------

Part 4: Extract Nginx Logs

    1: View Nginx Logs
    
        Monitor the incoming requests to Nginx in real-time.

            tail -f /var/log/nginx/access.log

    2: Save Logs to File

        Save the last 50 lines of access logs to a file in the user's home directory.
        
            sudo tail -n 50 /var/log/nginx/access.log > ~/nginx-logs.txt

        Verify that the file is created and has contents:
            
            cat ~/nginx-logs.txt

    3: Download Log File to Your Local Machine
    
        From a new terminal window on your local machine, run the "scp" command to download the log file:

        Using SSH Private Key

            scp -i day-08-key.pem ubuntu@54.210.85.112:~/nginx-logs.txt .

----------------------------------------------------------------------------------------------------------------------------------------------------

Commands Used

| Command | Purpose |
|---------|---------|
| "chmod 400 day-08-key.pem" | Restricts access permissions of private key file |
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

2. Permissions issue with Private Key ("day-08-key.pem")
- Problem: SSH connection failed with warning: "UNPROTECTED PRIVATE KEY FILE!".
- Cause: Private key was created with default permissions ("644"), which is too open.
- Resolution: Ran "chmod 400 day-08-key.pem" to restrict access permissions to the owner only.

----------------------------------------------------------------------------------------------------------------------------------------------------

What I Learned
- Cloud Instance Provisioning: How to configure and spin up a Linux instance (Ubuntu 22.04 LTS) in AWS.
- Security & Access Control: The importance of setting correct permissions for SSH private keys and managing firewalls via Cloud Security Groups.
- Service Installation: How to setup utility packages like Docker and web servers like Nginx.
- Remote Log Retrieval: How to view application logs in real-time, dump logs to flat files, and transfer them locally using "scp".