Date: 22 May 2026

🐧 Day 06: Linux Fundamentals: Read and Write Text Files

1. Create a file named "notes.txt"

        touch notes.txt

<img width="335" height="120" alt="Screenshot 2026-05-21 at 1 16 50 PM" src="https://github.com/user-attachments/assets/7f85e9c4-3a52-44f7-befd-90c9c20fcd21" />

2. Write first line using ">" redirection

        echo "This is First Line" > notes.txt

<img width="512" height="114" alt="Screenshot 2026-05-21 at 1 17 56 PM" src="https://github.com/user-attachments/assets/d7d7de45-cb3f-4cdf-818e-3fd45264f767" />

3. Add second line using ">>" redirection

        echo "This is Second Line" > notes.txt

<img width="530" height="140" alt="Screenshot 2026-05-21 at 1 18 23 PM" src="https://github.com/user-attachments/assets/d6e23041-0a88-45d4-8b00-c1c51b9888f4" />

4. Read the file content using "cat" command

        cat notes.txt

<img width="317" height="122" alt="Screenshot 2026-05-21 at 1 18 30 PM" src="https://github.com/user-attachments/assets/0d07d683-3e7a-4df4-8d75-30cc8515a673" />

5. Read the top most line from "notes.txt" file using "head" command

        head notest.txt -n 1

<img width="358" height="59" alt="Screenshot 2026-05-21 at 1 18 59 PM" src="https://github.com/user-attachments/assets/65531f71-2507-4f8e-9283-058c34941cec" />

6. Read the bottom line from "notes.txt" file using "tail" command

        tail notes.txt -n 1

<img width="353" height="54" alt="Screenshot 2026-05-21 at 1 19 06 PM" src="https://github.com/user-attachments/assets/9c2653a8-e373-4b21-bc42-49ed0fa01c4c" />

7. Write a new line and display it at the same time using "tee" command

        echo "This is Third Line using "tee" command | tee -a notes.txt

<img width="771" height="89" alt="Screenshot 2026-05-21 at 1 19 53 PM" src="https://github.com/user-attachments/assets/3a6fcd55-de32-475e-80a3-cd5771f03e33" />
