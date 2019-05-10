import sys

import pytest


def main():
    args = sys.argv[1:]
    print(args)

    sys.exit(pytest.main(args))


if __name__ == '__main__':
    main()
