/*
THIS FILE WAS AUTOGENERATED! DO NOT EDIT!
file to edit: /home/ubuntu/fastai_docs/dev_swift/01a_fastai_layers.ipynb/lastPathComponent

*/
        
import Path
import TensorFlow

public extension Tensor where Scalar: TensorFlowFloatingPoint {
    init(kaimingNormal shape: TensorShape, negativeSlope: Double = 1.0) {
        // Assumes Leaky ReLU nonlinearity
        let gain = Scalar(sqrt(2.0 / (1.0 + pow(negativeSlope, 2))))
        let spatialDimCount = shape.count - 2
        let receptiveField = shape[0..<spatialDimCount].contiguousSize
        let fanIn = shape[spatialDimCount] * receptiveField
        self.init(randomNormal: shape)
        self *= Tensor<Scalar>(gain/sqrt(Scalar(fanIn)))
    }
}

public extension Tensor where Scalar: TensorFlowFloatingPoint {
    func std() -> Tensor<Scalar> { return standardDeviation() }
    func std(alongAxes a: [Int]) -> Tensor<Scalar> { return standardDeviation(alongAxes: a) }
    func std(alongAxes a: Tensor<Int32>) -> Tensor<Scalar> { return standardDeviation(alongAxes: a) }
    func std(alongAxes a: Int...) -> Tensor<Scalar> { return standardDeviation(alongAxes: a) }
    func std(squeezingAxes a: [Int]) -> Tensor<Scalar> { return standardDeviation(squeezingAxes: a) }
    func std(squeezingAxes a: Tensor<Int32>) -> Tensor<Scalar> { return standardDeviation(squeezingAxes: a) }
    func std(squeezingAxes a: Int...) -> Tensor<Scalar> { return standardDeviation(squeezingAxes: a) }
}

import TensorFlow

public protocol FALayer: Layer {
    associatedtype Input
    associatedtype Output
    
    var delegate: LayerDelegate<Output> { get set }
    
    @differentiable
    func forward(_ input: Input) -> Output
}

public extension FALayer {
   @differentiable
   func call(_ input: Input) -> Output {
       let activation = forward(input)
       delegate.didProduceActivation(activation)
       return activation
   }
}

open class LayerDelegate<Output> {
    public init() {}
    
    open func didProduceActivation(_ activation: Output) {}
}


@_fixed_layout
public struct FADense<Scalar: TensorFlowFloatingPoint>: FALayer { 
    public var weight: Tensor<Scalar>
    public var bias: Tensor<Scalar>
    public typealias Activation = @differentiable (Tensor<Scalar>) -> Tensor<Scalar>
    @noDerivative public let activation: Activation
    
    @noDerivative public var delegate: LayerDelegate<Output> = LayerDelegate()

    public init(
        weight: Tensor<Scalar>,
        bias: Tensor<Scalar>,
        activation: @escaping Activation
    ) {
        self.weight = weight
        self.bias = bias
        self.activation = activation
    }

    @differentiable
    public func forward(_ input: Tensor<Scalar>) -> Tensor<Scalar> {
        return activation(matmul(input, weight) + bias)
    }
}

public extension FADense {
    init(_ nIn: Int, _ nOut: Int, activation: @escaping Activation = identity) {
        self.init(weight: Tensor(kaimingNormal: [nIn, nOut]),
                  bias: Tensor(zeros: [nOut]),
                  activation: activation)
    }
}


@_fixed_layout
public struct FANoBiasConv2D<Scalar: TensorFlowFloatingPoint>: FALayer {
    public var filter: Tensor<Scalar>
    public typealias Activation = @differentiable (Tensor<Scalar>) -> Tensor<Scalar>
    @noDerivative public let activation: Activation
    @noDerivative public let strides: (Int, Int)
    @noDerivative public let padding: Padding
    
    @noDerivative public var delegate: LayerDelegate<Output> = LayerDelegate()

    public init(
        filter: Tensor<Scalar>,
        activation: @escaping Activation,
        strides: (Int, Int),
        padding: Padding
    ) {
        self.filter = filter
        self.activation = activation
        self.strides = strides
        self.padding = padding
    }

    @differentiable
    public func forward(_ input: Tensor<Scalar>) -> Tensor<Scalar> {
        return activation(input.convolved2D(withFilter: filter,
                                            strides: (1, strides.0, strides.1, 1),
                                            padding: padding))
    }
}

public extension FANoBiasConv2D {
    init(
        filterShape: (Int, Int, Int, Int),
        strides: (Int, Int) = (1, 1),
        padding: Padding = .same,
        activation: @escaping Activation = identity
    ) {
        let filterTensorShape = TensorShape([
            filterShape.0, filterShape.1,
            filterShape.2, filterShape.3])
        self.init(
            filter: Tensor(kaimingNormal: filterTensorShape),
            activation: activation,
            strides: strides,
            padding: padding)
    }
}

public extension FANoBiasConv2D {
    init(_ cIn: Int, _ cOut: Int, ks: Int, stride: Int = 1, padding: Padding = .same,
         activation: @escaping Activation = identity){
        self.init(filterShape: (ks, ks, cIn, cOut),
                  strides: (stride, stride),
                  padding: padding,
                  activation: activation)
    }
}


@_fixed_layout
public struct FAConv2D<Scalar: TensorFlowFloatingPoint>: FALayer {
    public typealias Input = Tensor<Scalar>
    public typealias Output = Tensor<Scalar>
    
    public var filter: Tensor<Scalar>
    public var bias: Tensor<Scalar>
    public typealias Activation = @differentiable (Tensor<Scalar>) -> Tensor<Scalar>
    @noDerivative public let activation: Activation
    @noDerivative public let strides: (Int, Int)
    @noDerivative public let padding: Padding
    
    @noDerivative public var delegate: LayerDelegate<Output> = LayerDelegate()

    public init(
        filter: Tensor<Scalar>,
        bias: Tensor<Scalar>,
        activation: @escaping Activation,
        strides: (Int, Int),
        padding: Padding
    ) {
        self.filter = filter
        self.bias = bias
        self.activation = activation
        self.strides = strides
        self.padding = padding
    }

    @differentiable
    public func forward(_ input: Tensor<Scalar>) -> Tensor<Scalar> {
        return activation(input.convolved2D(withFilter: filter,
                                            strides: (1, strides.0, strides.1, 1),
                                            padding: padding) + bias)
    }
}

public extension FAConv2D {
    init(
        filterShape: (Int, Int, Int, Int),
        strides: (Int, Int) = (1, 1),
        padding: Padding = .same,
        activation: @escaping Activation = identity
    ) {
        let filterTensorShape = TensorShape([
            filterShape.0, filterShape.1,
            filterShape.2, filterShape.3])
        self.init(
            filter: Tensor(kaimingNormal: filterTensorShape),
            bias: Tensor(zeros: TensorShape([filterShape.3])),
            activation: activation,
            strides: strides,
            padding: padding)
    }
}

public extension FAConv2D {
    init(_ cIn: Int, _ cOut: Int, ks: Int, stride: Int = 1, padding: Padding = .same,
         activation: @escaping Activation = identity){
        self.init(filterShape: (ks, ks, cIn, cOut),
                  strides: (stride, stride),
                  padding: padding,
                  activation: activation)
    }
}


@_fixed_layout
public struct FAAvgPool2D<Scalar: TensorFlowFloatingPoint>: FALayer {
    @noDerivative let poolSize: (Int, Int, Int, Int)
    @noDerivative let strides: (Int, Int, Int, Int)
    @noDerivative let padding: Padding
    
    @noDerivative public var delegate: LayerDelegate<Output> = LayerDelegate()

    public init(
        poolSize: (Int, Int, Int, Int),
        strides: (Int, Int, Int, Int),
        padding: Padding
    ) {
        self.poolSize = poolSize
        self.strides = strides
        self.padding = padding
    }

    public init(poolSize: (Int, Int), strides: (Int, Int), padding: Padding = .valid) {
        self.poolSize = (1, poolSize.0, poolSize.1, 1)
        self.strides = (1, strides.0, strides.1, 1)
        self.padding = padding
    }
    
    public init(_ sz: Int, padding: Padding = .valid) {
        poolSize = (1, sz, sz, 1)
        strides = (1, sz, sz, 1)
        self.padding = padding
    }

    @differentiable
    public func forward(_ input: Tensor<Scalar>) -> Tensor<Scalar> {
        return input.averagePooled(kernelSize: poolSize, strides: strides, padding: padding)
    }
}


@_fixed_layout
public struct FAGlobalAvgPool2D<Scalar: TensorFlowFloatingPoint>: FALayer {
    @noDerivative public var delegate: LayerDelegate<Output> = LayerDelegate()
    
    public init() {}

    @differentiable
    public func forward(_ input: Tensor<Scalar>) -> Tensor<Scalar> {
        return input.mean(squeezingAxes: [1,2])
    }
}

extension Array: Layer where Element: Layer, Element.Input == Element.Output {
    public typealias Input = Element.Input
    public typealias Output = Element.Output
    
    @differentiable(vjp: _vjpApplied)
    public func call(_ input: Input) -> Output {
        var activation = input
        for layer in self {
            activation = layer(activation)
        }
        return activation
    }
    
    public func _vjpApplied(_ input: Input)
        -> (Output, (Output.CotangentVector) -> (Array.CotangentVector, Input.CotangentVector))
    {
        var activation = input
        var pullbacks: [(Input.CotangentVector) -> (Element.CotangentVector, Input.CotangentVector)] = []
        for layer in self {
            let (newActivation, newPullback) = layer.valueWithPullback(at: activation) { $0($1) }
            activation = newActivation
            pullbacks.append(newPullback)
        }
        func pullback(_ v: Input.CotangentVector) -> (Array.CotangentVector, Input.CotangentVector) {
            var activationGradient = v
            var layerGradients: [Element.CotangentVector] = []
            for pullback in pullbacks.reversed() {
                let (newLayerGradient, newActivationGradient) = pullback(activationGradient)
                activationGradient = newActivationGradient
                layerGradients.append(newLayerGradient)
            }
            return (Array.CotangentVector(layerGradients.reversed()), activationGradient)
        }
        return (activation, pullback)
    }
}

extension KeyPathIterable {
    public var keyPaths: [WritableKeyPath<Self, Tensor<Float>>] {
        return recursivelyAllWritableKeyPaths(to: Tensor<Float>.self)
    }
}
