function zk = hFun(k, xk, vk, landmarks)
%H_FUN Measurement model

n = size(landmarks, 1);
zk = zeros(n, 1);
if vk == 0
    vk = zeros(n, 1);
end

for i = 1:n
    zk(i) = norm(xk - landmarks(i, :)') + vk(i);
end

end

