import { useState, useEffect } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { useNavigate } from "react-router-dom";
import { z } from "zod";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { useToast } from "@/hooks/use-toast";
import { useAuth } from "@/hooks/use-auth";
import { User as UserIconLucide } from "lucide-react";

const profileFormSchema = z.object({
  display_name: z.string().min(2, "O nome de exibição deve ter pelo menos 2 caracteres").max(50, "O nome de exibição não pode ter mais de 50 caracteres").nullable(),
  bio: z.string().max(200, "A biografia não pode ter mais de 200 caracteres").nullable(),
  avatar_url: z.string().url("Insira uma URL de avatar válida").nullable(),
});

const Profile = () => {
  const { user, profile, loading, updateProfile, signOut } = useAuth();
  const { toast } = useToast();
  const navigate = useNavigate();
  const [isSubmitting, setIsSubmitting] = useState(false);

  const form = useForm<z.infer<typeof profileFormSchema>>({
    resolver: zodResolver(profileFormSchema),
    defaultValues: {
      display_name: profile?.display_name ?? "",
      bio: profile?.bio ?? "",
      avatar_url: profile?.avatar_url ?? "",
    },
  });

  useEffect(() => {
    if (!loading && !user) {
      navigate("/login");
    }
    if (profile) {
      form.reset({
        display_name: profile.display_name ?? "",
        bio: profile.bio ?? "",
        avatar_url: profile.avatar_url ?? "",
      });
    }
  }, [user, profile, loading, navigate, form]);

  const onSubmit = async (values: z.infer<typeof profileFormSchema>) => {
    setIsSubmitting(true);
    try {
      await updateProfile({
        display_name: values.display_name,
        bio: values.bio,
        avatar_url: values.avatar_url,
      });
      toast({
        title: "Perfil atualizado!",
        description: "Suas informações foram salvas com sucesso.",
      });
    } catch (error: any) {
      console.error("Failed to update profile:", error);
      toast({
        title: "Erro ao atualizar perfil",
        description: error.message ?? "Não foi possível atualizar seu perfil. Tente novamente.",
        variant: "destructive",
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  if (loading || !user) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <p className="text-muted-foreground">Carregando perfil...</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-background via-muted to-background px-4 py-10">
      <Card className="w-full max-w-2xl shadow-2xl">
        <CardHeader className="flex flex-col items-center text-center">
          <Avatar className="h-24 w-24 mb-4 border-2 border-primary">
            <AvatarImage src={profile?.avatar_url ?? undefined} alt={profile?.display_name ?? "User Avatar"} />
            <AvatarFallback className="bg-primary text-primary-foreground text-4xl font-bold">
              {profile?.display_name ? profile.display_name[0].toUpperCase() : <UserIconLucide className="h-12 w-12" />}
            </AvatarFallback>
          </Avatar>
          <CardTitle className="text-3xl font-bold">{profile?.display_name || "Seu Perfil"}</CardTitle>
          <CardDescription className="text-lg text-muted-foreground">
            Gerencie suas informações de perfil.
          </CardDescription>
        </CardHeader>
        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
            <CardContent className="space-y-4">
              <FormField
                control={form.control}
                name="display_name"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Nome de Exibição</FormLabel>
                    <FormControl>
                      <Input placeholder="Seu nome ou apelido" {...field} value={field.value ?? ""} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="bio"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Biografia (opcional)</FormLabel>
                    <FormControl>
                      <Textarea placeholder="Conte um pouco sobre você..." rows={3} {...field} value={field.value ?? ""} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="avatar_url"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>URL do Avatar (opcional)</FormLabel>
                    <FormControl>
                      <Input placeholder="https://exemplo.com/seu-avatar.jpg" {...field} value={field.value ?? ""} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </CardContent>
            <CardFooter className="flex flex-col gap-4">
              <Button type="submit" className="w-full" disabled={isSubmitting}>
                {isSubmitting ? "Salvando..." : "Salvar Alterações"}
              </Button>
              <Button variant="outline" className="w-full" onClick={() => signOut()} disabled={isSubmitting}>
                Sair
              </Button>
            </CardFooter>
          </form>
        </Form>
      </Card>
    </div>
  );
};

export default Profile;