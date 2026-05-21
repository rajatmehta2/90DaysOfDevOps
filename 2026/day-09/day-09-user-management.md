Date: 25 May 2026

🐧 Day 09 – Linux User & Group Management Challenge

Task 1: Create Users

Create three users with home directories and set their passwords: "tokyo", "berlin", and "professor".

1. Create users with home directories:

        sudo useradd -m tokyo
        sudo useradd -m berlin
        sudo useradd -m professor

2. Set passwords (using chpasswd for automation):

        echo "tokyo:tokyo123" | sudo chpasswd
        echo "berlin:berlin123" | sudo chpasswd
        echo "professor:prof123" | sudo chpasswd

Verification:

tail -n 3 /etc/passwd

    <img width="449" height="99" alt="Screenshot 2026-05-21 at 5 09 54 PM" src="https://github.com/user-attachments/assets/c39a8c0e-3a70-4f1d-80c3-3819e2015e40" />

ls -la /home

    <img width="564" height="179" alt="Screenshot 2026-05-21 at 5 10 46 PM" src="https://github.com/user-attachments/assets/5885dc50-4956-4bd0-a622-438ebf6c1c53" />

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Task 2: Create Groups

Create two groups: "developers" and "admins".

1. Create the groups:

        sudo groupadd developers
        sudo groupadd admins

Verification:

grep -E "developers|admins" /etc/group

    <img width="603" height="116" alt="Screenshot 2026-05-21 at 5 14 57 PM" src="https://github.com/user-attachments/assets/476c1c22-38b8-43c8-a02c-8eac334f911a" />

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Task 3: Assign Users to Groups

1. Assign users to the created groups:

        sudo usermod -aG developers tokyo
        sudo usermod -aG developers,admins berlin
        sudo usermod -aG admins professor

Verification:

id tokyo

    <img width="613" height="68" alt="Screenshot 2026-05-21 at 5 16 16 PM" src="https://github.com/user-attachments/assets/55365e9a-cded-493e-8ef7-14f90045ce24" />

id berlin

    <img width="756" height="62" alt="Screenshot 2026-05-21 at 5 16 35 PM" src="https://github.com/user-attachments/assets/b6916e5c-6abc-480a-805e-94310b22d375" />

id professor

    <img width="696" height="66" alt="Screenshot 2026-05-21 at 5 17 01 PM" src="https://github.com/user-attachments/assets/ca8d7dac-cbcd-45e6-ad9c-a2c8aeedb567" />

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Task 4: Setup Shared Directory

1. Create a directory "/opt/dev-project".

   sudo mkdir -p /opt/dev-project

3. Change the group ownership of "/opt/dev-project" to "developers".

    sudo chgrp developers /opt/dev-project

4. Set the directory permissions to "775" (rwxrwxr-x) to allow group members to read/write/execute.

    sudo chmod 775 /opt/dev-project
    ls -ld /opt/dev-project

        <img width="598" height="119" alt="Screenshot 2026-05-21 at 5 20 13 PM" src="https://github.com/user-attachments/assets/bb2f96e2-c12a-4e19-b3af-1f555cdd9761" />

6. Test by simulating file creation as "tokyo" and "berlin".

    sudo su tokyo -c "touch /opt/dev-project/tokyo-file.txt"
   
        <img width="760" height="23" alt="Screenshot 2026-05-21 at 5 21 22 PM" src="https://github.com/user-attachments/assets/6de4f0d6-eba6-4e3b-93e4-8192543a64cf" />

    sudo su berlin -c "touch /opt/dev-project/berlin-file.txt"

        <img width="775" height="21" alt="Screenshot 2026-05-21 at 5 21 40 PM" src="https://github.com/user-attachments/assets/c05f80e2-e75f-4efd-9e81-f4923f93415d" />


8. Verify that an unauthorized user ("professor") gets a permission error.

    sudo su professor -c "touch /opt/dev-project/prof-file.txt"

        <img width="793" height="76" alt="Screenshot 2026-05-21 at 5 21 58 PM" src="https://github.com/user-attachments/assets/79facadf-8974-4b13-a74f-97f0e6881b59" />


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Task 5: Team Workspace Setup

1. Create user "nairobi" with a home directory.

        sudo useradd -m nairobi
        echo "nairobi:nai123" | sudo chpasswd

2. Create group "project-team".

        sudo groupadd project-team

3. Add "nairobi" and "tokyo" to "project-team".

        sudo usermod -aG project-team nairobi
        sudo usermod -aG project-team tokyo

4. Create directory "/opt/team-workspace".

        sudo mkdir -p /opt/team-workspace

5. Set directory group to "project-team" and permissions to "775".

        sudo chgrp project-team /opt/team-workspace
        sudo chmod 775 /opt/team-workspace

6. Test by simulating file creation as "nairobi" and "tokyo", and test permission denial for "berlin".

        sudo su nairobi -c "touch /opt/team-workspace/nairobi-file.txt"
        sudo su tokyo -c "touch /opt/team-workspace/tokyo-team-file.txt"
        sudo su berlin -c "touch /opt/team-workspace/berlin-fail.txt"

        <img width="838" height="330" alt="Screenshot 2026-05-21 at 5 53 12 PM" src="https://github.com/user-attachments/assets/22ac13bd-0af3-4619-b79f-39fc5c2f6d05" />


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

What I Learned:

    1. User and Group Management: Understood the usage of command-line tools like "useradd", "groupadd", and "usermod" with options like "-m" (create home directory) and "-aG" (add to supplementary groups).

    2. Access Control Lists & Directory Permissions: Realized how numeric permissions like "775" (rwxrwxr-x) control write access to groups, while safeguarding the directory structure from non-member modifications (verified through "Permission denied" outputs on unauthorized attempts).
    
    3. Automated User Setup: Explored tools like "chpasswd" for setting up multiple user passwords in non-interactive shell scripts or Docker sandboxes, making automation and provisioning significantly faster.
