-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local Node = {}
Node.__index = Node

function Node.new(n, t)
    return setmetatable({ notification = n, time = t, next = nil, prev = nil }, Node)
end

local notifications = { mt = {} }
notifications.__index = notifications

local properties = {
    head = nil,
    tail = nil,
    rnode = nil,
    lnode = nil,
    distance = 0,
}

function notifications.new(max_distance)
    properties.MAX = max_distance or 0
    return setmetatable(properties, notifications)
end

function notifications:append(n, t)
    local new_node = Node.new(n, t)
    if not self.head then
        self.head = new_node
        self.tail = new_node
        self.lnode = new_node
        self.rnode = new_node
        self.distance = 1
    else
        new_node.prev = self.tail
        self.tail.next = new_node
        self.tail = new_node

        -- rnode == old tail -> rnode is_attached
        if self.rnode == new_node.prev then
            self.rnode = new_node
            if self.distance + 1 > self.MAX then
                self.lnode = self.lnode.next
            else
                self.distance = self.distance + 1
            end
        end
    end
end

function notifications:is_rnode_tail()
    return self.rnode == self.tail
end

function notifications:retail()
    self.distance = 0
    self.rnode = self.tail
    self.lnode = self.rnode
    while self.lnode ~= self.head and self.distance < self.MAX do
        self.distance = self.distance + 1
        self.lnode = self.lnode.prev
    end
end

-- sliding happens only when already at MAX
function notifications:rslide()
    if self.rnode ~= self.tail then
        self.lnode = self.lnode.next
        self.rnode = self.rnode.next
        return true
    end
    return false
end

-- sliding happens only when already at MAX
function notifications:lslide()
    if self.lnode ~= self.head then
        self.lnode = self.lnode.prev
        self.rnode = self.rnode.prev
        return true
    end
    return false
end

function notifications:delete_sequence()
    if self.lnode.prev then
        self.lnode.prev.next = self.rnode.next
    else
        self.head = self.rnode.next
    end

    if self.rnode.next then
        self.rnode.next.prev = self.lnode.prev
    else
        self.tail = self.lnode.prev
    end
end

-- callback for the sequence rnode -> lnode
function notifications:apply_to(callback, ...)
    local current = self.rnode
    while current and current ~= self.lnode.prev do
        callback(self, ...)
        current = current.prev
    end
end

function notifications.mt:__call(...)
    return notifications.new(...)
end

return setmetatable(notifications, notifications.mt)
