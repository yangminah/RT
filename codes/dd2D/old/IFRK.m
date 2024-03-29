function [x, ES, FS]= IFRK(x, M, h, every, dp, RK)
	ES = zeros(M/every+1,1); FS = zeros(M/every+1,1);kk = 0;
	for tt = 1 : M
		x = IFRK_step(x, h, RK, dp);
        if tt == 1
            %tic
        end
		if mod(tt, every) == 1
            %toc
			%display([norm(x(:,1)) norm(x(:,2)) norm(x(:,3))])
			kk = kk+1; [ES(kk), FS(kk)] = computeE(x, dp);
			if ismember(1, isnan(x)) || ismember(1, isinf(x))
				%display(tt*h) 
                ES = ES(1:kk); FS=FS(1:kk);
				break
			end
            %tic
		end
	end
end

function update = IFRK_step(x, h, RK, dp)
	s = length(RK.b);
	stages = cell(s,1); PP=0;
	% ks, x, PP are stored as vectors (flattened) within this function.
	stages{1} = flatten(NL(x, dp));
	x = flatten(x);
	for ii = 2 : s
		PP = h*lincomIF(RK.A(ii, 1:ii-1), RK.cx(ii, 1:ii-1), RK.cmat, stages(1:ii-1));
		stages{ii} = flatten(NL(boxify3(RK.cmat(RK.cx(ii,ii))*x + PP, dp.NxNz), dp));
	end
	%new PP for update
	PP = h*lincomIF(RK.b, RK.cx(end,:), RK.cmat, stages);
	update = boxify3(RK.cmat(RK.cx(end-1,end))*x+PP, dp.NxNz);
end

%lincom outputs a flat vector
function lincom = lincomIF(A, cx, cmat, k)
	lincom = A(1)*cmat(cx(1))*k{1};
	for ii = 2 : length(k)
		lincom = lincom + A(ii)*cmat(cx(ii))*k{ii};
	end
end
