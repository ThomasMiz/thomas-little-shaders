using System;
using System.IO;

namespace ShaderRunner
{
    class Program
    {
        static void Main(string[] args)
        {
            string[] files = Directory.GetFiles(Directory.GetCurrentDirectory(), "*.glsl");
            if (files.Length == 0)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("Error!");
                Console.ResetColor();
                Console.WriteLine("No .glsl files were found in the current directory. Make sure to place one of your shaders here:");
                Console.WriteLine(Directory.GetCurrentDirectory());
                return;
            }

            Console.WriteLine("Running: {0}", files[0]);
            new ShaderWindow(files[0]).Run();
        }
    }
}