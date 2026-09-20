import tkinter as tk
import webbrowser
import subprocess

DOWNLOAD_URL = "https://github.com/"  # Replace with your GitHub download link.

root = tk.Tk()
root.title("Roblox Password")
root.geometry("380x210")
root.configure(bg="black")
root.attributes("-topmost", True)

second = tk.Toplevel(root)
second.title("Roblox Password")
second.geometry("380x210")
second.configure(bg="black")
second.attributes("-topmost", True)

def make_window(win):
    tk.Label(
        win,
        text="ROBLOX PASSWORD",
        fg="white",
        bg="black",
        font=("Consolas", 18, "bold")
    ).pack(pady=(18, 8))

    tk.Entry(
        win,
        show="*",
        bg="white",
        fg="black",
        font=("Consolas", 12),
        width=25
    ).pack()

    tk.Button(
        win,
        text="DOWNLOAD",
        command=lambda: webbrowser.open(DOWNLOAD_URL),
        font=("Consolas", 11, "bold")
    ).pack(pady=10)

    # Exit instruction is shown ONLY inside the moving windows.
    tk.Label(
        win,
        text="Press E to exit",
        fg="white",
        bg="black",
        font=("Consolas", 10)
    ).pack()

make_window(root)
make_window(second)

# Open CMD as a separate visible window.
cmd = subprocess.Popen(["cmd.exe"])

screen_w = root.winfo_screenwidth()
screen_h = root.winfo_screenheight()

positions = [
    [40, 100, 28, 21],
    [500, 350, -24, 27],
]

def stop(event=None):
    try:
        cmd.terminate()
    except Exception:
        pass
    try:
        second.destroy()
    except Exception:
        pass
    root.destroy()

root.bind_all("<KeyPress-e>", stop)
root.bind_all("<KeyPress-E>", stop)

def move():
    for i, win in enumerate((root, second)):
        x, y, dx, dy = positions[i]
        w, h = 380, 210

        x += dx
        y += dy

        if x <= 0 or x + w >= screen_w:
            dx = -dx
            x = max(0, min(x, screen_w - w))

        if y <= 0 or y + h >= screen_h:
            dy = -dy
            y = max(0, min(y, screen_h - h))

        positions[i] = [x, y, dx, dy]
        win.geometry(f"{w}x{h}+{x}+{y}")

    root.after(10, move)

move()
root.mainloop()
