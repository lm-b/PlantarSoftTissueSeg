% Law's Texture energy Features
% Lynda Brady
function [filteredImage]= lawstexten_im(imInGray, filter)


% Law 1-D vectors
% Length 3
L3=[1,2,1]; % Level
E3=[1,0,-1]; %Edge
S3=[1,-2,1]; %Spot
% Length 5
L5=[1,4,6,4,1];  %(Level)
E5=[-1,-2,0,2,1];  %(Edge)
S5=[-1,0,2,0,-1];  %(Spot)
R5=[1,-4,6,-4,1];  %(Ripple)
W5=[-1,2,0,-2,1];  %(Wave)

%     all3vects={L3,E3,S3};
%     all5vects={L5,E5,S5,R5,W5};
%
%  % Law 2D masks
%  k=1;
%  for i=1:length(all3vects)
%      j=i;
%      while j<length(all3vects)+1
%          all3mask{k}=all3vects{i}'*all3vects{j};
%          j=j+1;
%          k=k+1;
%      end
%  end
%  % 3 masks: L3L3, L3E3, L3S3, E3E3, E3S3, S3S3
%  k=1;
% for i=1:length(all5vects)
%      j=i;
%      while j<length(all5vects)+1
%          all5mask{k}=all5vects{i}'*all5vects{j};
%          j=j+1;
%          k=k+1;
%      end
% end
%  % 5 masks: L5L5, L5E5, L5S5, L5R5, L5W5, E5E5, E5S5, E5R5, E5W5, S5S5, S5R5, S5W5,
%  % R5R5, R5W5, W5W5
%     % X5Y5 and Y5X5 measure oppositite features, but average is overall (eg
%     % L5E5 is horizontal "edginess" and E5L5 is vertical"edginess", average
%     % is just "edginess"
%
% %all3mask={[1,2,1;2,4,2;1,2,1],[1,0,-1;2,0,-2;1,0,-1],[1,-2,1;2,-4,2;1,-2,1],[1,0,-1;0,0,0;-1,0,1],[1,-2,1;0,0,0;-1,2,-1],[1,-2,1;-2,4,-2;1,-2,1]};

switch filter
    case L3L3
        filteredImage=conv2(imInGray, all3mask{1});
    case L3E3
        filteredImage=conv2(imInGray, all3mask{2});
    case L3S3
        filteredImage=conv2(imInGray, all3mask{3});
    case E3E3
        filteredImage=conv2(imInGray, all3mask{4});
    case E3S3
        filteredImage=conv2(imInGray, all3mask{5});
    case S3S3
        filteredImage=conv2(imInGray, all3mask{6});
    case L5L5
        filteredImage=conv2(imInGray, all5mask{1});
    case L5E5
        filteredImage=conv2(imInGray, all5mask{2});
    case L5S5
        filteredImage=conv2(imInGray, all5mask{3});
    case L5R5
        filteredImage=conv2(imInGray, all5mask{4});
    case L5W5
        filteredImage=conv2(imInGray, all5mask{5});
    case E5E5
        filteredImage=conv2(imInGray, all5mask{6});
    case E5S5
        filteredImage=conv2(imInGray, all5mask{7});
    case E5R5
        filteredImage=conv2(imInGray, all5mask{8});
    case E5W5
        filteredImage=conv2(imInGray, all5mask{9});
    case S5S5
        filteredImage=conv2(imInGray, all5mask{10});
    case S5R5
        filteredImage=conv2(imInGray, all5mask{11});
    case S5W5
        filteredImage=conv2(imInGray, all5mask{12});
    case R5R5
        filteredImage=conv2(imInGray, all5mask{13});
    case R5W5
        filteredImage=conv2(imInGray, all5mask{14});
    case W5W5
        filteredImage=conv2(imInGray, all5mask{15});
end


end