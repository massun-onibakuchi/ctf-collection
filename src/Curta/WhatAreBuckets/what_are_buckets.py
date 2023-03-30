import sys
from collections import deque
from hashlib import sha3_256
from typing import List

# chat-gpt 🙏


def work(state: int, op: int) -> int:
    if op >> 2 == 0:
        if (op & 2) == 2:
            state <<= 8
        state &= 0xffffff00ff
        if (op & 1) == 1:
            state |= (state >> 16) & 0xff00
        if (op & 2) == 2:
            state >>= 8
    elif (op & 5) == 4:
        if (op & 2) == 2:
            state = (state & 0xff00ff00) >> 8 | (state & 0x00ff00ff) << 8
        flow0 = (state >> 8) & 0xff
        flow1 = ((state >> 16) & 0xff) - (state & 0xff)
        flow = min(flow0, flow1)
        state -= flow << 8
        state += flow
        if (op & 2) == 2:
            state = (state & 0xff00ff00) >> 8 | (state & 0x00ff00ff) << 8
    return state


def workAll(state: int, commands: int) -> int:
    for i in range(85):
        state = work(state, (commands >> (i * 3)) & 7)
    return state


def verify(start: int, solution: int) -> bool:
    state = workAll(start, solution ^ int.from_bytes(
        sha3_256(start.to_bytes(32, 'big')).digest(), 'big'))
    return state & 0xFFFF == 1

# credit: karmacoma.eth and chat-gpt


def bfs(start, condition_fn=None):
    """
    Performs a breadth-first search from start to goal using successors_fn to generate
    successor states. Returns a list of actions leading from start to goal, or None if
    no path is found.
    """
    def successors_fn(node):
        # Note that the successors_fn function is defined to generate the next states from the current node,
        return [(op, work(node, op)) for op in range(8)]

    # initialize the queue with the starting state and an empty path
    queue = deque([(start, [])])
    # keep track of visited states to avoid cycles
    visited = set([start])

    while queue:
        # dequeue the next state and path from the queue
        state, path = queue.popleft()
        # print("hex(state), path :>>", hex(state), path)
        # check if we've reached the goal state
        if (condition_fn and condition_fn(state, path)):
            return path
        # generate the next states from the current state
        neighbors = successors_fn(state)
        for (op, next_state) in neighbors:
            if next_state not in visited:
                # add the next state and path to the queue
                visited.add(next_state)
                next_path = path + [op]  # add op to the command list
                queue.append((next_state, next_path))


if __name__ == '__main__':

    def condition_fn(node, path):
        # check if we've reached the goal state
        # in this example, the goal state is defined as a node with the least significant 16 bits equal to 1
        return node & 0xFFFF == 1

    def search_bfs(node: int) -> List[int]:
        # find the path from the starting node to the target node
        # If a path is found, it is returned as a list of commands. If no path is found, None is returned
        path = bfs(node, condition_fn)
        if path:
            print('🥳 Found path!', path)
            return path
        else:
            print('😭 No path found')
            return None

    search_bfs(int(sys.argv[1], 16))
