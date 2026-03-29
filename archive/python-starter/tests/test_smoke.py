from fightcue import get_banner


def test_banner() -> None:
    assert get_banner() == "FightCue is ready."
