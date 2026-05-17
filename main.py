from time import sleep

from gpiozero import LED


def main():
    print("Hello from docker-pi-poc!")
    led = LED(17)
    led.on()
    sleep(5)
    led.off()


if __name__ == "__main__":
    main()
