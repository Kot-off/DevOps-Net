import sentry_sdk

sentry_sdk.init(
    dsn="https://00c8245332cca0260235a929579b2822@o4511060901363712.ingest.us.sentry.io/4511060905951232",
    send_default_pii=True
)

def make_error():
    division_by_zero = 1 / 0

print("Отправляю привет в Sentry...")
try:
    make_error()
except Exception as e:
    sentry_sdk.set_tag("student", "Anton")
    sentry_sdk.capture_exception(e)
    print("Ошибка успешно отправлена!")