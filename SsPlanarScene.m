classdef SsPlanarScene < SsImage
    % Sample a flat image and illuminate it.
    
    properties
        width;
        height;
        pixelWidth;
        pixelHeight;
        illuminant;
    end
    
    methods
        function obj = SsPlanarScene(varargin)
            parser = inputParser();
            parser.addParameter('width', 1, @isnumeric);
            parser.addParameter('height', 1, @isnumeric);
            parser.addParameter('pixelWidth', 640, @isnumeric);
            parser.addParameter('pixelheight', 480, @isnumeric);
            parser.addParameter('illuminant', SsSpectrum(400:10:700), @(s) isa(s, 'SsSpectrum'));
            ssParseMagically(parser, obj, varargin{:});
            
            obj.wavelengths = obj.illuminant.wavelengths;
            
            obj.declareSlot(SsSlot('reflectance', 'SsImage'));
        end
    end
    
    methods (Access = protected)
        function imageSample = computeSample(obj, x, y)
            % get reflectance image from slot
            reflectance = obj.findSlot('reflectance');
            if isempty(reflectance)
                imageSample = [];
                return;
            end
            reflectanceSample = reflectance.computeSample(x,y);
            
            % resample illuminant to match reflectance
            illum = obj.illuminant.resample( ...
                reflectance.wavelengths, ...
                'method', 'spd');
            
            % multiplu illuminant across the reflectance image 
            imageSample = reflectanceSample ...
                .* repmat(illum.magnitudes(:)', numel(x), 1);
        end
    end
end