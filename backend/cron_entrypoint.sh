#!/bin/sh
set -e

# Write cron.d file with env vars inline (cron.d supports KEY=value at top of file)
# This is the only reliable way to pass Docker env vars to cron jobs
cat > /etc/cron.d/fiscio << EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
DATABASE_URL=${DATABASE_URL}
SECRET_KEY=${SECRET_KEY}

${RECURRING_SCHEDULE:-0 0 * * *} root python /app/generate_recurring.py >> /var/log/fiscio-recurring.log 2>&1
${REMINDERS_SCHEDULE:-0 * * * *} root python /app/send_reminders.py >> /var/log/fiscio-reminders.log 2>&1
${IPCA_SCHEDULE:-0 0 * * *} root python /app/ipca_ingest.py >> /var/log/fiscio-ipca.log 2>&1
EOF

chmod 0644 /etc/cron.d/fiscio

# Create log files so tail -f works even before first run
touch /var/log/fiscio-recurring.log /var/log/fiscio-reminders.log /var/log/fiscio-ipca.log

echo "Cron started with schedules:"
echo "  recurring : ${RECURRING_SCHEDULE:-0 0 * * *}"
echo "  reminders : ${REMINDERS_SCHEDULE:-0 * * * *}"
echo "  ipca      : ${IPCA_SCHEDULE:-0 0 * * *}"
cat /etc/cron.d/fiscio

exec cron -f
