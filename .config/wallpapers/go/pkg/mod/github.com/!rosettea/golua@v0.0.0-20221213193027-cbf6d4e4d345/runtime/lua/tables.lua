local t = {3, 2, 1, x = "abc", ["zz"] = 12}
print(t[1])
--> =3
print(#t)
--> =3
t[4]=2
print(#t)
--> =4
print(t["x"] .. t.zz)
--> =abc12

t[6]=1
t[5]=1
print(#t)
--> =6

t[6]=nil
print(#t)
--> =5

t[4]=nil
t[5]=nil
print(#t)
--> =3

t[3.2] = 5
print(t[3.2])
--> =5

t[5e2] = "hi"
print(t[500])
--> =hi

print(#t)
--> =3

t.xxx = nil
print(t.xxx)
--> =nil

print(pcall(function() t[nil] = 2 end))
--> ~false\t.*index is nil

print(pcall(function() t[0/0] = 2 end))
--> ~false\t.*index is NaN

do
    local t = {"x", "y"}
    local a, x = next(t)
    local b, y = next(t, a)
    if a < b then
        print(a..b, x..y)
    else
        print(b..a, y..x)
    end
    --> =12	xy

    print(next(t, b))
    --> =nil

    print(pcall(next, t, "abc"))
    --> ~^false

    t[b] = nil
    print(next(t, a))
    --> =nil

    print(next({}))
    --> =nil
end

-- custom length as used in table module functions
do
    local t = {"x", "y"}
    debug.setmetatable(t, {__len=function() return 10 end})
    table.insert(t, 5)
    print(t[11])
    --> =5
end
do
    local t = {"x", "y"}
    debug.setmetatable(t, {__len=function() return "hi" end})
    print(pcall(table.insert, t, 5))
    --> ~false\t.*
end
do
    local t = {"x", "y"}
    debug.setmetatable(t, {__len=function() error("haha") end})
    print(pcall(table.insert, t, 5))
    --> ~false\t.* haha
end
