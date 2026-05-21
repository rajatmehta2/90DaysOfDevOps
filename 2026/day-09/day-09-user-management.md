Date: 25 May 2026

🐧 Day 09 – Linux User & Group Management Challenge

Task 1: Create Users

    Create three users with home directories and set their passwords: `tokyo`, `berlin`, and `professor`.

        1. Create users with home directories

            sudo useradd -m tokyo
            sudo useradd -m berlin
            sudo useradd -m professor

        2. Set passwords (using chpasswd for automation)

            echo "tokyo:tokyo123" | sudo chpasswd
            echo "berlin:berlin123" | sudo chpasswd
            echo "professor:prof123" | sudo chpasswd

    Verification:

        tail -n 3 /etc/passwd

        ls -la /home

----------------------------------------------------------------------------------------------------------------------------------------------------

Task 2: Create Groups

    Create two groups: `developers` and `admins`.

        1. Create the groups

            sudo groupadd developers
            sudo groupadd admins

    Verification:

        grep -E "developers|admins" /etc/group

----------------------------------------------------------------------------------------------------------------------------------------------------

Task 3: Assign Users to Groups

    Assign users to the created groups:

        sudo usermod -aG developers tokyo
        sudo usermod -aG developers,admins berlin
        sudo usermod -aG admins professor

    Verification:

        id tokyo
        id berlin
        id professor

----------------------------------------------------------------------------------------------------------------------------------------------------

Task 4: Setup Shared Directory

    1. Create a directory `/opt/dev-project`.

        sudo mkdir -p /opt/dev-project

    2. Change the group ownership of `/opt/dev-project` to `developers`.

        sudo chgrp developers /opt/dev-project

    3. Set the directory permissions to `775` (rwxrwxr-x) to allow group members to read/write/execute.

        sudo chmod 775 /opt/dev-project
        ls -ld /opt/dev-project

    4. Test by simulating file creation as `tokyo` and `berlin`.

        sudo su tokyo -c "touch /opt/dev-project/tokyo-file.txt"
        sudo su berlin -c "touch /opt/dev-project/berlin-file.txt"

    5. Verify that an unauthorized user (`professor`) gets a permission error.

        sudo su professor -c "touch /opt/dev-project/prof-file.txt"

----------------------------------------------------------------------------------------------------------------------------------------------------

Task 5: Team Workspace Setup

    1. Create user `nairobi` with a home directory.

        sudo useradd -m nairobi
        echo "nairobi:nai123" | sudo chpasswd

    2. Create group `project-team`.

        sudo groupadd project-team

    3. Add `nairobi` and `tokyo` to `project-team`.

        sudo usermod -aG project-team nairobi
        sudo usermod -aG project-team tokyo

    4. Create directory `/opt/team-workspace`.

        sudo mkdir -p /opt/team-workspace

    5. Set directory group to `project-team` and permissions to `775`.

        sudo chgrp project-team /opt/team-workspace
        sudo chmod 775 /opt/team-workspace

    6. Test by simulating file creation as `nairobi` and `tokyo`, and test permission denial for `berlin`.

        sudo su nairobi -c "touch /opt/team-workspace/nairobi-file.txt"
        sudo su tokyo -c "touch /opt/team-workspace/tokyo-team-file.txt"
        sudo su berlin -c "touch /opt/team-workspace/berlin-fail.txt"

----------------------------------------------------------------------------------------------------------------------------------------------------

What I Learned:

    1. User and Group Management: Understood the usage of command-line tools like `useradd`, `groupadd`, and `usermod` with options like `-m` (create home directory) and `-aG` (add to supplementary groups).

    2. Access Control Lists & Directory Permissions: Realized how numeric permissions like `775` (rwxrwxr-x) control write access to groups, while safeguarding the directory structure from non-member modifications (verified through `Permission denied` outputs on unauthorized attempts).
    
    3. Automated User Setup: Explored tools like `chpasswd` for setting up multiple user passwords in non-interactive shell scripts or Docker sandboxes, making automation and provisioning significantly faster.

----------------------------------------------------------------------------------------------------------------------------------------------------