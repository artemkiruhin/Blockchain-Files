from datetime import datetime, timedelta
from web3_provider import Provider


class User:
    def __init__(self, address: str, username: str):
        self.address = address
        self.username = username


class Auction:
    def __init__(self,
                 token_id: int,
                 time_started: datetime,
                 duration: int,
                 min_price: int,
                 max_price: int,
                 owner: str):
        self.token_id = token_id
        self.time_started = time_started
        self.duration = duration
        self.min_price = min_price
        self.max_price = max_price
        self.owner = owner
        self.timestamp = time_started + timedelta(seconds=self.duration)
        self.locked_during_auction = True
        self.winner = ""


class UserService:
    users: list[User]

    def get_user(self, username: str, address: str) -> User:
        for u in self.users:
            if u.username == username and u.address == address:
                return u

    def get_user_by_address(self, address: str) -> User:
        for u in self.users:
            if u.address == address:
                return u


class AuctionService:
    auctions: list[Auction]

    @staticmethod
    def get_auction(token_id: int, owner: str) -> Auction:
        for auc in AuctionService.auctions:
            if auc.token_id == token_id and auc.owner == owner:
                return auc

    @staticmethod
    def start(auction: Auction):
        # web3_provider/provider realisation
        pass

    @staticmethod
    def interrupt(token_id: int, owner: str):
        auction = AuctionService.get_auction(token_id, owner)
        auction.locked_during_auction = False
        # web3_provider/provider realisation
        pass

    @staticmethod
    def finish(token_id: int, owner: str):
        auction = AuctionService.get_auction(token_id, owner)
        auction.locked_during_auction = False
        # web3_provider/provider realisation
        pass

    @staticmethod
    def bit(token_id: int, owner: str, bitter: str, value: int):
        auction = AuctionService.get_auction(token_id, owner)
        # web3_provider/provider realisation
