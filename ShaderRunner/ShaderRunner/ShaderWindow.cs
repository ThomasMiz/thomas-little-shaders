using System;
using System.Numerics;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using Silk.NET.Maths;
using TrippyGL;

namespace ShaderRunner
{
    internal class ShaderWindow : WindowBase
    {
        const string vertexShaderCode = "#version 330 core\nin vec3 vPosition;\nvoid main() { gl_Position = vec4(vPosition, 1.0); }";

        private readonly string fragmentShaderFile;

        VertexBuffer<VertexPosition> squareBuffer;
        ShaderProgram shaderProgram;

        ShaderUniform resolutionUniform;
        ShaderUniform timeUniform;
        ShaderUniform mouseUniform;

        public ShaderWindow(string fragmentShaderFile) : base("TrippyGL Shader Runner", 0)
        {
            this.fragmentShaderFile = fragmentShaderFile ?? throw new ArgumentNullException(nameof(fragmentShaderFile));
        }

        protected override void OnLoad()
        {
            Span<VertexPosition> vertexData = stackalloc VertexPosition[]
            {
                new Vector3(-1, -1, 0),
                new Vector3(1, -1, 0),
                new Vector3(-1, 1, 0),
                new Vector3(1, 1, 0)
            };

            squareBuffer = new VertexBuffer<VertexPosition>(graphicsDevice, vertexData, BufferUsage.StaticDraw);

            shaderProgram = ShaderProgram.FromCode<VertexPosition>(graphicsDevice, vertexShaderCode, File.ReadAllText(fragmentShaderFile), "vPosition");

            if (!shaderProgram.Uniforms.IsEmpty)
            {
                resolutionUniform = shaderProgram.Uniforms["u_resolution"];
                timeUniform = shaderProgram.Uniforms["u_time"];
                mouseUniform = shaderProgram.Uniforms["u_mouse"];
            }

            graphicsDevice.DepthTestingEnabled = false;
            graphicsDevice.BlendingEnabled = false;
            graphicsDevice.ClearColor = Vector4.UnitW;
        }

        protected override void OnRender(double dt)
        {
            graphicsDevice.Clear(ClearBuffers.Color);

            if (!timeUniform.IsEmpty)
                timeUniform.SetValueFloat((float)Window.Time);
            if (!mouseUniform.IsEmpty && InputContext.Mice.Count != 0)
                mouseUniform.SetValueVec2(InputContext.Mice[0].Position);

            graphicsDevice.VertexArray = squareBuffer;
            graphicsDevice.ShaderProgram = shaderProgram;
            graphicsDevice.DrawArrays(PrimitiveType.TriangleStrip, 0, squareBuffer.StorageLength);
        }

        protected override void OnResized(Vector2D<int> size)
        {
            graphicsDevice.SetViewport(0, 0, (uint)size.X, (uint)size.Y);

            if (!resolutionUniform.IsEmpty)
                resolutionUniform.SetValueVec2(size.X, size.Y);
        }

        protected override void OnUnload()
        {
            squareBuffer.Dispose();
            shaderProgram.Dispose();
        }
    }
}
