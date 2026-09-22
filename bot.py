import os
import asyncio
import json
import aiohttp
import discord

# =========================
# SETTINGS
# =========================

TOKEN = os.getenv("DISCORD_BOT_TOKEN")

TRACKED_USERS = [
    3842338968,
    3806223773,
    1160586028,
    2450648402
]

DISCORD_CHANNEL_ID = 1551901875433902101
CHECK_INTERVAL = 30

MESSAGE_FILE = "tracker_messages.json"

# =========================
# DISCORD
# =========================

intents = discord.Intents.default()
client = discord.Client(intents=intents)

last_status = {}
tracker_messages = {}


# =========================
# SAVE MESSAGE IDS
# =========================

def load_messages():

    global tracker_messages

    try:

        with open(
            MESSAGE_FILE,
            "r"
        ) as file:

            tracker_messages = json.load(file)

    except:

        tracker_messages = {}


def save_messages():

    with open(
        MESSAGE_FILE,
        "w"
    ) as file:

        json.dump(
            tracker_messages,
            file
        )


# =========================
# ROBLOX API
# =========================

async def get_presences():

    async with aiohttp.ClientSession() as session:

        async with session.post(
            "https://presence.roblox.com/v1/presence/users",
            json={
                "userIds": TRACKED_USERS
            }
        ) as response:

            if response.status != 200:

                print(
                    "Roblox API error:",
                    response.status
                )

                return []

            data = await response.json()

    return data.get(
        "userPresences",
        []
    )


async def get_user_name(user_id):

    async with aiohttp.ClientSession() as session:

        async with session.get(
            f"https://users.roblox.com/v1/users/{user_id}"
        ) as response:

            if response.status != 200:

                return str(user_id)

            data = await response.json()

    return data.get(
        "name",
        str(user_id)
    )


# =========================
# STATUS
# =========================

def get_status(presence):

    if presence is None:

        return "OFFLINE"

    presence_type = presence.get(
        "userPresenceType",
        0
    )

    if presence_type == 0:

        return "OFFLINE"

    elif presence_type == 2:

        return "IN_GAME"

    else:

        return "ONLINE"


# =========================
# BUTTONS
# =========================

class RobloxButtons(discord.ui.View):

    def __init__(
        self,
        game_url=None,
        profile_url=None
    ):

        super().__init__(
            timeout=None
        )

        if game_url:

            self.add_item(
                discord.ui.Button(
                    label="🎮 JOIN GAME",
                    style=discord.ButtonStyle.link,
                    url=game_url
                )
            )

        self.add_item(
            discord.ui.Button(
                label="👤 PROFILE",
                style=discord.ButtonStyle.link,
                url=profile_url
            )
        )


# =========================
# CREATE MESSAGE
# =========================

async def make_message(
    user_id,
    status,
    presence
):

    username = await get_user_name(
        user_id
    )

    profile_url = (
        f"https://www.roblox.com/users/"
        f"{user_id}/profile"
    )

    # -------------------------
    # OFFLINE
    # -------------------------

    if status == "OFFLINE":

        content = (
            f"⚫ **{username} is OFFLINE!**\n"
            f"👤 {profile_url}"
        )

        view = RobloxButtons(
            profile_url=profile_url
        )

        return content, view

    # -------------------------
    # ONLINE
    # -------------------------

    if status == "ONLINE":

        content = (
            f"🟢 **{username} is ONLINE!**\n"
            f"👤 {profile_url}"
        )

        view = RobloxButtons(
            profile_url=profile_url
        )

        return content, view

    # -------------------------
    # IN GAME
    # -------------------------

    place_id = None

    if presence:

        place_id = presence.get(
            "placeId"
        )

    if place_id:

        game_url = (
            f"https://www.roblox.com/games/"
            f"{place_id}"
        )

        content = (
            f"🎮 **{username} is IN GAME!**\n"
            f"👤 {profile_url}"
        )

        view = RobloxButtons(
            game_url=game_url,
            profile_url=profile_url
        )

        return content, view

    else:

        content = (
            f"🎮 **{username} is IN GAME!**\n"
            f"👤 {profile_url}"
        )

        view = RobloxButtons(
            profile_url=profile_url
        )

        return content, view


# =========================
# UPDATE USER MESSAGE
# =========================

async def update_user_message(
    channel,
    user_id,
    status,
    presence
):

    content, view = await make_message(
        user_id,
        status,
        presence
    )

    message_id = tracker_messages.get(
        str(user_id)
    )

    # =========================
    # EXISTING MESSAGE
    # =========================

    if message_id:

        try:

            message = await channel.fetch_message(
                int(message_id)
            )

            await message.edit(
                content=content,
                view=view
            )

            return

        except discord.NotFound:

            print(
                "Old message was deleted. Creating a new one."
            )

        except discord.Forbidden:

            print(
                "Missing permission to edit message."
            )

            return

    # =========================
    # NEW MESSAGE
    # =========================

    message = await channel.send(
        content,
        view=view
    )

    tracker_messages[
        str(user_id)
    ] = message.id

    save_messages()


# =========================
# TRACKER
# =========================

async def tracker():

    await client.wait_until_ready()

    channel = client.get_channel(
        DISCORD_CHANNEL_ID
    )

    if channel is None:

        print(
            "ERROR: Discord channel not found."
        )

        return

    print(
        "Roblox tracker started."
    )

    while not client.is_closed():

        try:

            presences = await get_presences()

            presence_by_id = {
                p["userId"]: p
                for p in presences
            }

            for user_id in TRACKED_USERS:

                presence = presence_by_id.get(
                    user_id
                )

                status = get_status(
                    presence
                )

                old_status = last_status.get(
                    user_id
                )

                # =========================
                # FIRST CHECK
                # =========================

                if old_status is None:

                    await update_user_message(
                        channel,
                        user_id,
                        status,
                        presence
                    )

                    last_status[user_id] = status

                    continue

                # =========================
                # STATUS CHANGED
                # =========================

                if status != old_status:

                    await update_user_message(
                        channel,
                        user_id,
                        status,
                        presence
                    )

                    last_status[user_id] = status

                    username = await get_user_name(
                        user_id
                    )

                    print(
                        username,
                        "changed to",
                        status
                    )

        except Exception as error:

            print(
                "Tracker error:",
                error
            )

        await asyncio.sleep(
            CHECK_INTERVAL
        )


# =========================
# BOT START
# =========================

@client.event
async def on_ready():

    print(
        f"Bot is online as {client.user}"
    )

    if not hasattr(
        client,
        "tracker_started"
    ):

        client.tracker_started = True

        load_messages()

        asyncio.create_task(
            tracker()
        )


# =========================
# TOKEN
# =========================

if not TOKEN:

    print(
        "ERROR: DISCORD_BOT_TOKEN is not set."
    )

    raise SystemExit(1)


# =========================
# START
# =========================

client.run(TOKEN)