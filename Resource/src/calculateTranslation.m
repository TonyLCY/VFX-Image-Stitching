function tran = calculateTranslation(pairs)
    % RANSAC
    THRES = 40;
    REP = 40;
    n = size(pairs,1);
    tmp_cnt = 0;
    tmp_tran = zeros(2);
    for j = 1:REP
        id = randsample(n,2);
        vec = pairs(id(1),1:2)-pairs(id(1),3:4);
        c = 0; % temp inlier
        for k = 1:n
            if norm(pairs(k,1:2) - pairs(k,3:4) - vec) <= THRES
                c = c + 1;
            end
        end
        if c > tmp_cnt
            tmp_cnt = c;
            tmp_tran = vec;
        end
    end
    %disp([tmp_cnt,tmp_tran]);
    vecSum = zeros(1,2);
    for k = 1:n
        if norm(pairs(k,1:2) - pairs(k,3:4) - tmp_tran) <= THRES
            vecSum = vecSum + pairs(k,1:2) - pairs(k,3:4);
        end
    end
    tran = vecSum/tmp_cnt;
    disp([tmp_cnt,tran]);
end