import { createClient } from "npm:@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: cors });
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { ...cors, "Content-Type": "application/json" },
    });
  }

  // Verify the caller is a legitimate authenticated user.
  const userClient = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: authHeader } } },
  );

  const {
    data: { user },
    error: authError,
  } = await userClient.auth.getUser();

  if (authError || !user) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { ...cors, "Content-Type": "application/json" },
    });
  }

  // Use the service role key to perform admin-level deletion.
  const adminClient = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const uid = user.id;

  // Delete user data in FK-safe order before removing the auth record.
  // If cascade deletes are configured on auth.users, these are redundant but harmless.
  const tables = [
    "ai_usage_log",
    "ai_analyses",
    "ai_hand_analyses",
    "player_read_notes",
    "player_reads",
    "rake_presets",
    "hands",
    "sessions",
    "profiles",
  ];

  for (const table of tables) {
    const { error } = await adminClient
      .from(table)
      .delete()
      .eq("user_id", uid);
    if (error) {
      console.error(`Failed to delete from ${table}:`, error.message);
      // Non-fatal: continue — the auth deletion below is the critical step.
    }
  }

  const { error: deleteError } = await adminClient.auth.admin.deleteUser(uid);
  if (deleteError) {
    console.error("Failed to delete auth user:", deleteError.message);
    return new Response(JSON.stringify({ error: "Failed to delete account" }), {
      status: 500,
      headers: { ...cors, "Content-Type": "application/json" },
    });
  }

  return new Response(JSON.stringify({ success: true }), {
    status: 200,
    headers: { ...cors, "Content-Type": "application/json" },
  });
});
