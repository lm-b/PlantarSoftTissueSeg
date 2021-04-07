function [filteredImage]=LawsFilt(imInGray, filter)

% Description:
    % takes in a grayscale image and computes the Laws Texture maska and
    % returns grayscale image filtered by the mask. Takes standard labels
    % as a string


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
all3vects={L3,E3,S3};
all5vects={L5,E5,S5,R5,W5};

switch filter
    case 'L3L3'
        mask=all3vects{1}'*all3vects{1};
        filteredImage=imfilter(imInGray, mask);
    case 'L3E3'
        mask=all3vects{1}'*all3vects{2};
        filteredImage=imfilter(imInGray, mask);
    case 'L3S3'
        mask=all3vects{1}'*all3vects{3};
        filteredImage=imfilter(imInGray, mask);
    case 'E3E3'
        mask=all3vects{2}'*all3vects{2};
        filteredImage=imfilter(imInGray, mask);
    case 'E3S3'
        mask=all3vects{2}'*all3vects{3};
        filteredImage=imfilter(imInGray, mask);
    case 'S3S3'
        mask=all3vects{3}'*all3vects{3};
        filteredImage=imfilter(imInGray, mask);
    case 'L5L5'
        mask=all5vects{1}'*all5vects{1};
        filteredImage=imfilter(imInGray, mask);
    case 'L5E5'
        mask=all5vects{1}'*all5vects{2};
        filteredImage=imfilter(imInGray, mask);
    case 'L5S5'
        mask=all5vects{1}'*all5vects{3};
        filteredImage=imfilter(imInGray, mask);
    case 'L5R5'
       mask=all5vects{1}'*all5vects{4};
        filteredImage=imfilter(imInGray, mask);
    case 'L5W5'
        mask=all5vects{1}'*all5vects{5};
        filteredImage=imfilter(imInGray, mask);
    case 'E5E5'
        mask=all5vects{2}'*all5vects{2};
        filteredImage=imfilter(imInGray, mask);
    case 'E5S5'
        mask=all5vects{2}'*all5vects{3};
        filteredImage=imfilter(imInGray, mask);
    case 'E5R5'
        mask=all5vects{2}'*all5vects{4};
        filteredImage=imfilter(imInGray, mask);
    case 'E5W5'
        mask=all5vects{2}'*all5vects{5};
        filteredImage=imfilter(imInGray, mask);
    case 'S5S5'
        mask=all5vects{3}'*all5vects{3};
        filteredImage=imfilter(imInGray, mask);
    case 'S5R5'
        mask=all5vects{3}'*all5vects{4};
        filteredImage=imfilter(imInGray, mask);
    case 'S5W5'
        mask=all5vects{3}'*all5vects{5};
        filteredImage=imfilter(imInGray, mask);
    case 'R5R5'
        mask=all5vects{4}'*all5vects{4};
        filteredImage=imfilter(imInGray, mask);
    case 'R5W5'
        mask=all5vects{4}'*all5vects{5};
        filteredImage=imfilter(imInGray, mask);
    case 'W5W5'
        mask=all5vects{5}'*all5vects{5};
        filteredImage=imfilter(imInGray, mask);
end