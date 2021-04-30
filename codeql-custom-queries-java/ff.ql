import java

from Method method
where method.hasName("ff")
select method, method.getDeclaringType(), method.getLocation()