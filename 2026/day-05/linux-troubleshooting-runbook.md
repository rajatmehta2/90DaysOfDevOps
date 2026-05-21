Date: 21 May 2026

🐧 Day 05: Linux Troubleshooting Runbook: Nginx Web Server

1. Environment & Filesystem Sanity

Command 1: OS Architecture and Kernel Check

     uname -a

<img width="1033" height="91" alt="Screenshot 2026-05-21 at 12 12 25 PM" src="https://github.com/user-attachments/assets/9ee3ef17-fee5-436f-a42e-bf9a494c3ed7" />

Command 2: OS Version Details

     cat /etc/os-release

<img width="728" height="408" alt="Screenshot 2026-05-21 at 12 22 45 PM" src="https://github.com/user-attachments/assets/f3097e36-dd0f-4d11-9aa3-3f34ceacd04b" />

Command 3: Write Verification (Filesystem Sanity Check)

     mkdir /home/sandbox/runbook-demo && cp /etc/hosts /home/sandbox/runbook-demo/hosts-copy && ls -l /home/sandbox/runbook-demo

<img width="1129" height="125" alt="Screenshot 2026-05-21 at 12 26 45 PM" src="https://github.com/user-attachments/assets/1fd8dd87-53ce-4402-985c-ed436f5a019f" />


2. Snapshot: CPU & Memory

Command 4: Process-Specific Resource Utilization

     ps -o pid,pcpu,pmem,comm -C nginx

<img width="727" height="94" alt="Screenshot 2026-05-21 at 12 34 21 PM" src="https://github.com/user-attachments/assets/ad5eafa7-fcba-4fd7-bab4-6f395a43627c" />

Command 5: Global Memory Utilization

     free -h

<img width="695" height="155" alt="Screenshot 2026-05-21 at 12 34 51 PM" src="https://github.com/user-attachments/assets/53b18fb7-34cb-4dc9-8f96-618832dcbc90" />


3. Snapshot: Disk & IO

Command 6: Storage Space Allocation

     df -h /

<img width="421" height="120" alt="Screenshot 2026-05-21 at 12 36 03 PM" src="https://github.com/user-attachments/assets/82cc8c65-39f0-42fa-a763-9082c8fad360" />

Command 7: Log Directory Capacity

     du -sh /var/log

<img width="336" height="89" alt="Screenshot 2026-05-21 at 12 36 56 PM" src="https://github.com/user-attachments/assets/bcaa9a32-6ee9-4efa-97fc-9afa049d305a" />


4. Snapshot: Network

Command 8: Network Socket Binding

     ss -tulpn | grep nginx

<img width="1157" height="81" alt="Screenshot 2026-05-21 at 12 38 34 PM" src="https://github.com/user-attachments/assets/2574ef73-5a99-48ac-b691-e84c552de8ed" />

Command 9: Local Endpoint Validation

     curl -I http://localhost

<img width="637" height="186" alt="Screenshot 2026-05-21 at 12 40 01 PM" src="https://github.com/user-attachments/assets/abbdb312-3fa6-49f0-8847-efe069ba176d" />


5. Logs Reviewed

Command 10: Systemd Unit Logs

     journalctl -u nginx -n 10 --no-pager

<img width="1384" height="243" alt="Screenshot 2026-05-21 at 12 40 50 PM" src="https://github.com/user-attachments/assets/86a1f20d-2bb9-4778-afdf-ded672b692f2" />

Command 11: Native Service Error Logs

     tail -n 10 /var/log/nginx/error.log

<img width="1425" height="366" alt="Screenshot 2026-05-21 at 12 44 12 PM" src="https://github.com/user-attachments/assets/e4de32a1-1acc-46e8-a394-aa6790bf2649" />


6. Quick Findings

          Operational Status: Healthy. The Nginx service is running normally with exceptionally low resource usage.

          Storage & Network Safety: Disk utilization is well within normal limits (44%), write operations pass successfully, and ports 80/443 are properly bound and responding with valid 200 OK headers.

8. If This Worsens (Next Steps)

Should the service degrade, encounter high latency, or drop active connections, execute the following emergency operations:

     1. Graceful Worker Refresh Strategy: Avoid sudden service disruptions by executing a hot config validation and safe reload to drop dead sockets without dropping active users:

          nginx -t && systemctl reload nginx

<img width="754" height="143" alt="Screenshot 2026-05-21 at 12 49 43 PM" src="https://github.com/user-attachments/assets/2f8dd958-0b0b-4ae7-84c2-2e5c5b54c787" />

     2. Examine Live Thread Blockages with strace: Track OS system calls in real-time to locate hanging worker tasks or slow I/O operations directly on an active worker process:

          strace -p <worker_pid> -c -T

<img width="638" height="519" alt="Screenshot 2026-05-21 at 12 54 34 PM" src="https://github.com/user-attachments/assets/d6dfe6c8-fa31-4648-ac0b-6d8baee85c53" />

     3. Elevate Log Verbosity Levels: If connections are dropping silently, modify the main configuration (/etc/nginx/nginx.conf) error directive to capture deep application behavior data:

          error_log /var/log/nginx/error.log debug;
