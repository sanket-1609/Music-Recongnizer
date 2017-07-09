function Y = locmax(X) %Y has points of X which are local maxima
X = X(:)'; %Make X a row
nbr = [X,X(end)] >= [X(1),X];
Y = X .* nbr(1:end-1) .* (1-nbr(2:end)); %greater than prev * greater than next

